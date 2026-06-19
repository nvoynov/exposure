# rakelib/photo.rake
require 'fileutils'
require 'json'
require 'yaml'

JEKYLL_DIR            = File.join(File.dirname(__FILE__), "..", "site")
SERIES_COLLECTION_DIR = File.join(JEKYLL_DIR, "_series")
ASSETS_DIR            = File.join(JEKYLL_DIR, "assets", "gallery")
CONFIG_CACHE_FILE     = File.join(File.dirname(__FILE__), "..", "local_config.yml")

# Helper to format folder/file names into safe URLs
def generate_slug(name)
  name.downcase.gsub(/[^a-z0-9\-_]/, '_').squeeze('_')
end

# Extract EXIF metadata via ExifTool batch execution
def extract_series_exif(series_path)
  puts "  [ExifTool] Batch gathering metadata for folder..."
  cmd = "exiftool -json -fast -DateTimeOriginal -Title -Description \"#{series_path}\""
  output = `#{cmd}`
  return {} if output.strip.empty?

  JSON.parse(output).each_with_object({}) do |file_data, map|
    base_name = File.basename(file_data["SourceFile"], ".*")
    map[base_name] = file_data
  end
rescue => e
  puts "  [Error] Failed to gather batch EXIF: #{e.message}"
  {}
end

# Parses Pandoc Markdown file headers and extracts the pure title, tags, and content body
def parse_pandoc_readme(readme_path, fallback_title)
  return [fallback_title, [], ""] unless File.exist?(readme_path)

  lines = File.readlines(readme_path)
  title = fallback_title
  tags = []
  content_lines = []

  lines.each do |line|
    if line.start_with?('%')
      # Check if the Pandoc line defines tags (e.g., % tags: landscape, autumn, melancholy)
      if line.downcase.start_with?('% tags:')
        tags_raw = line.sub(/% tags:/i, '').strip
        tags = tags_raw.split(',').map(&:strip).reject(&:empty?)
      elsif title == fallback_title
        # Otherwise, if it's the first standard Pandoc line, treat it as the Title
        extracted = line.sub('%', '').strip
        title = extracted unless extracted.empty?
      end
    else
      content_lines << line
    end
  end

  [title, tags, content_lines.join("").strip]
end

namespace :photo do
  desc "Synchronize and optimize TIFF photos from a source directory into the website"
  task :import do
    # 1. Environment verification
    magick_present   = system("command -v magick > /dev/null 2>&1")
    exiftool_present = system("command -v exiftool > /dev/null 2>&1")

    unless magick_present && exiftool_present
      abort "Error: Please ensure 'imagemagick' and 'exiftool' are installed and accessible in your PATH."
    end

    # 2. Smart storage configuration lookup
    source_dir = ENV['SOURCE']
    
    if source_dir.nil? || source_dir.empty?
      if File.exist?(CONFIG_CACHE_FILE)
        cached_config = YAML.load_file(CONFIG_CACHE_FILE) rescue {}
        source_dir = cached_config['source_photos_path']
        puts "Using cached source photo directory: #{source_dir}"
      else
        print "Enter the absolute path to your source TIFF directory: "
        source_dir = STDIN.gets.chomp
      end
    end

    unless File.directory?(source_dir)
      abort "Error: Directory '#{source_dir}' does not exist."
    end

    FileUtils.mkdir_p(SERIES_COLLECTION_DIR)
    puts "Starting photo optimization workflow..."

    # 3. Scan source tree
    Dir.glob(File.join(source_dir, "*")).each do |series_path|
      next unless File.directory?(series_path)

      series_folder_name = File.basename(series_path)
      
      # Determine if this series should be hidden from the public archive listing page
      # (Triggers if the directory name begins with an underscore or a dot)
      is_hidden = series_folder_name.start_with?('_') || series_folder_name.start_with?('.')
      
      # Strip the leading hidden characters for URL slug safety
      clean_folder_name = series_folder_name.sub(/^[._]/, '')
      series_slug = generate_slug(clean_folder_name)

      puts "\n=== Processing series: #{series_folder_name} (Hidden: #{is_hidden}) ==="

      full_dest_dir   = File.join(ASSETS_DIR, series_slug, "full")
      thumbs_dest_dir = File.join(ASSETS_DIR, series_slug, "thumbs")
      FileUtils.mkdir_p(full_dest_dir)
      FileUtils.mkdir_p(thumbs_dest_dir)

      exif_catalog = extract_series_exif(series_path)
      series_photos_data = []
      valid_photo_slugs = []

      # Gather all target files into a raw array first
      raw_tif_files = Dir.glob(File.join(series_path, "*.{tif,tiff,TIF,TIFF}"))

      # PURE FUNCTIONAL SORTING:
      # Creates a brand new immutable chronological sequence based on EXIF or mtime data.
      # Completely avoids unsafe in-place array mutations or variables re-assignments.
      chronological_tif_files = raw_tif_files.sort_by do |tif_path|
        file_name = File.basename(tif_path, ".*")
        file_exif = exif_catalog[file_name] || {}
        
        # Fallback to file system modification time if EXIF field is missing
        file_exif["DateTimeOriginal"] || File.mtime(tif_path).to_s
      end

      # Now iterate through the beautifully ordered chronological array sequence
      chronological_tif_files.each do |tif_path|
        file_name = File.basename(tif_path, ".*")
        photo_slug = generate_slug(file_name)
        valid_photo_slugs << photo_slug
        
        webp_full_name  = "#{photo_slug}.webp"
        webp_thumb_name = "#{photo_slug}_thumb.webp"

        full_path  = File.join(full_dest_dir, webp_full_name)
        thumb_path = File.join(thumbs_dest_dir, webp_thumb_name)

        # Smart conversion check
        need_conversion = !File.exist?(full_path) || 
                          !File.exist?(thumb_path) || 
                          File.mtime(tif_path) > File.mtime(full_path)

        if need_conversion
          print "  Optimizing: #{file_name}..."
          system("magick", tif_path, "-resize", "1920x1080>", "-quality", "82", full_path)
          system("magick", tif_path, "-resize", "600x400>", "-quality", "75", thumb_path)
          puts " Done."
        else
          puts "  Skipped (cached): #{file_name}"
        end

        file_exif = exif_catalog[file_name] || {}
        series_photos_data << {
          "filename"     => webp_full_name,
          "thumbnail"    => webp_thumb_name,
          "title"        => file_exif["Title"] || file_name,
          "description"  => file_exif["Description"] || "",
          "date"         => file_exif["DateTimeOriginal"] || ""
        }
      end

      # Orphan assets cleanup
      Dir.glob(File.join(full_dest_dir, "*.webp")).each do |file|
        File.delete(file) unless valid_photo_slugs.include?(File.basename(file, ".webp"))
      end
      Dir.glob(File.join(thumbs_dest_dir, "*.webp")).each do |file|
        File.delete(file) unless valid_photo_slugs.include?(File.basename(file, "_thumb.webp"))
      end

      # Parse the Pandoc Markdown README file safely
      readme_path = File.join(series_path, "README.md")
      series_title, series_tags, pure_text_content = parse_pandoc_readme(readme_path, clean_folder_name)

      front_matter = {
        "layout"         => "series",
        "title"          => series_title,
        "slug"           => series_slug,
        "hidden"         => is_hidden,
        "tags"           => series_tags, # Injects the parsed tags array into Front Matter
        "photos"         => series_photos_data,
        "preview_photos" => series_photos_data.sample(5)
      }

      File.open(File.join(SERIES_COLLECTION_DIR, "#{series_slug}.md"), "w") do |f|
        f.puts front_matter.to_yaml
        f.puts "---"
        f.puts "\n#{pure_text_content}"
      end
      puts "  [Jekyll] Updated series entry: site/_albums/#{series_slug}.md"
    end

    # 4. Save path setup configuration cache on successful execution
    unless File.exist?(CONFIG_CACHE_FILE)
      config_payload = { 'source_photos_path' => source_dir }
      File.open(CONFIG_CACHE_FILE, "w") { |f| f.puts config_payload.to_yaml }
      
      env_file = File.join(File.dirname(__FILE__), "..", ".env")
      File.open(env_file, "w") { |f| f.puts "PHOTOS_SOURCE_PATH=#{source_dir}" }
      
      puts "\n[Config] Directory saved to local_config.yml and .env for future sessions."
    end

    puts "\nSynchronization complete!"
  end
end
