# lib/exposure/tasks/build_site_album.rb
require 'fileutils'
require_relative 'base'
require_relative '../decorator'
require_relative '../presenter'

module Exposure
  module Task

    # Micro-use-case compiling assets and layouts for a singular web album
    class BuildSiteAlbum < Base

      # Initialize clean use case state without infrastructure coupling
      def initialize
        # Pull the global path once upon initialization to clean call signature
        @gallery_path = Exposure::Config.instance.gallery_path
      end

      # @param album [Model::Album] clean domain aggregate instance
      # @param target_site_path [String] destination route inside Jekyll
      # @param assets_dest_root [String] shared assets directory root
      # @return [Array<String>] collection of local thumbnails paths built
      def call(album, target_site_path, assets_dest_root)
        album_local_thumbs = []

        # 1. Wrap inside decorator and compile monolithic release markdown
        web_album = Decorator::SiteAlbum.new(album)
        jekyll_md_path = 
          File.join(target_site_path, "_series", "#{web_album.slug}.md")

        FileUtils.mkdir_p(File.dirname(jekyll_md_path))
        File.write(jekyll_md_path, Presenter::SiteAlbum.new.call(web_album))

        # 2. Synchronize directories infrastructure
        album_dest_full   = File.join(assets_dest_root, web_album.slug, "full")
        album_dest_thumbs = File.join(assets_dest_root, web_album.slug, "thumbs")

        FileUtils.mkdir_p(album_dest_full)
        FileUtils.mkdir_p(album_dest_thumbs)

        # 3. Stream master photo files through high-level clean ports
        web_album.images.each do |image|
          source_file_path = 
            File.join(@gallery_path, web_album.dirname, image.filename)
          next unless File.exist?(source_file_path)

          full_out_name  = "#{File.basename(image.filename, '.*')}.webp"
          thumb_out_name = "#{File.basename(image.filename, '.*')}_thumb.webp"
          
          full_dest_path  = File.join(album_dest_full, full_out_name)
          thumb_dest_path = File.join(album_dest_thumbs, thumb_out_name)

          image_transformation.convert_to_full(source: source_file_path, destination: full_dest_path)
          image_transformation.convert_to_thumbnail(source: source_file_path, destination: thumb_dest_path)

          album_local_thumbs << thumb_dest_path
        end

        # 4. Bake localized album Open Graph scattered collage deck layout
        config = Exposure::Config.instance
        album_cover_dest = 
          File.join(assets_dest_root, web_album.slug, "og_album_cover.jpg")

        # Smart cache guard bypass: track delta collection sizes changes
        existing_thumbs_count = Dir.glob(File.join(album_dest_thumbs, "*.webp")).size
        collection_changed = web_album.images.size != existing_thumbs_count

        # Force rebuild if the file is physically missing or if collection grew
        if !File.exist?(album_cover_dest) || collection_changed
          base_samples = album_local_thumbs.first(5)
          
          # Dynamically append the blank holder if the active pool is immature
          while base_samples.size < 5
            base_samples << config.blank_holder_path
          end

          image_transformation.create_scattered_portfolio(
            images: base_samples,
            compiled_wm: config.watermark_path,
            output: album_cover_dest
          )
        end

        album_local_thumbs
      end
    end
  end
end
