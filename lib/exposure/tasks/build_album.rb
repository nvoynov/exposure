require 'yaml'
require_relative '../model'
require_relative '../ports'

# lib/exposure/tasks/build_album.rb
require 'yaml'

module Exposure
  module Task

    # Core application interactor responsible for analyzing directory streams
    class BuildAlbum
      MD_LEDGER  = "ALBUM.md"
      YML_LEDGER = "ALBUM.yml"

      # @param metadata_port [Ports::ExifMetadata] strict abstraction boundary tool
      def initialize(metadata_port:)
        # Fail-Fast parameter validation tracking (Rule #2)
        raise ArgumentError, "Missing required metadata_port!" unless metadata_port
        
        @metadata_port = metadata_port
      end
      
      # @param album_path [String] path to a specific album directory
      # @return [Model::Album] compiled, synchronized, read-only domain aggregate
      def call(album_path)
        dirname = File.basename(album_path)
        
        tif_files = Dir
          .glob(File.join(album_path, "*.{tif,tiff,TIF,TIFF}"))
          .map { File.basename(it) }

        return nil if tif_files.empty?

        # CLEAN ARCHITECTURE IN ACTION: Querying the dependency via the abstract boundary port
        exif_catalog = @metadata_port.extract(album_path, tif_files)

        yml_path = File.join(album_path, YML_LEDGER)
        meta_config = sync_technical_ledger(yml_path, dirname, tif_files, exif_catalog)

        md_path = File.join(album_path, MD_LEDGER)
        sync_artistic_narrative(md_path, meta_config)

        ordered_images = meta_config[:manual_storyboard_order].map do |filename|
          img_key = File.basename(filename, ".*")
          img_meta = meta_config[:images_catalog][img_key.to_sym] || {}
          
          created_at_time = 
            if img_meta[:exif_time]
              Time.parse(img_meta[:exif_time])
            else
              File.mtime(File.join(album_path, filename))
            end

          Model::Image.new(
            filename:    filename,
            title:       img_meta[:exif_title] || File.basename(filename, ".*"),
            description: img_meta[:exif_description] || "",
            tags:        img_meta[:seo_tags] || [],
            created_at:  created_at_time
          )
        end

        Model::Album.new(
          dirname:     dirname,
          title:       meta_config[:album_title],
          description: meta_config[:seo_description],
          story:       File.exist?(md_path) ? File.read(md_path) : "",
          tags:        meta_config[:global_tags],
          cover:       meta_config[:cover_image_filename],
          images:      ordered_images,
          hidden:      dirname.start_with?('_')
        )
      end

      private

      # @return [Hash] symbol-keyed localized metadata configurations directory ledger
      # @return [Hash] symbol-keyed localized metadata configurations
      def sync_technical_ledger(yml_path, dirname, tif_files, exif_catalog)
        # Default chronological sorting pattern to establish baseline indexes
        sorted_by_exif = 
          tif_files.sort_by do |f|
            img_key = File.basename(f, ".*")
            exif_catalog[img_key.to_sym]&.[](:exif_time) || ""
          end

        unless File.exist?(yml_path)
          # BUILD LOGIC FROM SCRATCH: Assemble fresh configurations metrics
          first_f = sorted_by_exif.first
          last_f  = sorted_by_exif.last
          
          first_time = exif_catalog[File.basename(first_f, ".*").to_sym]&.[](:exif_time) if first_f
          last_time  = exif_catalog[File.basename(last_f, ".*").to_sym]&.[](:exif_time) if last_f
          
          time_span_desc = 
            if first_time && last_time
              start_d = Time.parse(first_time).strftime('%B %d, %Y')
              end_d   = Time.parse(last_time).strftime('%B %d, %Y')
              "This album archives photographs captured between #{start_d} and #{end_d}."
            else
              "A fine-art photographic series exploration."
            end

          catalog = {}
          tif_files.each do |f|
            img_key = File.basename(f, ".*").to_sym
            meta = exif_catalog[img_key] || {}
            catalog[img_key] = {
              exif_title: meta[:exif_title] || File.basename(f, ".*"),
              exif_time:  meta[:exif_time],
              seo_tags:   ["photography"]
            }
          end

          initial_config = {
            album_title:          dirname.capitalize.gsub('_', ' '),
            cover_image_filename: sorted_by_exif.first || "",
            seo_description:      time_span_desc,
            global_tags:          ["series"],
            manual_storyboard_order: sorted_by_exif,
            images_catalog:       catalog
          }

          File.write(yml_path, YAML.dump(initial_config))
          return initial_config
        end

        # MERGE / SYNCHRONIZATION LOGIC: Load existing state and fix gaps
        existing_config = YAML.load_file(yml_path).transform_keys(&:to_sym)
        existing_config[:images_catalog] = 
          existing_config[:images_catalog].transform_keys(&:to_sym)
        
        current_order = existing_config[:manual_storyboard_order] || []
        orphans = tif_files - current_order
        
        if orphans.any?
          existing_config[:manual_storyboard_order] = current_order + orphans
          
          orphans.each do |f|
            img_key = File.basename(f, ".*").to_sym
            meta = exif_catalog[img_key] || {}
            existing_config[:images_catalog][img_key] = {
              exif_title: meta[:exif_title] || File.basename(f, ".*"),
              exif_time:  meta[:exif_time],
              seo_tags:   ["photography"]
            }
          end
          
          File.write(yml_path, YAML.dump(existing_config))
        end

        existing_config
      end

      # @return [TrueClass, FalseClass] confirms Markdown scaffolding generation
      def sync_artistic_narrative(md_path, meta_config)
        return false if File.exist?(md_path)

        # Build clean Pandoc Markdown metadata header scaffolding according to requirements specifications
        scaffold = <<~MARKDOWN
          % #{meta_config[:album_title]}
          % tags: #{meta_config[:global_tags].join(', ')}

          Write your artistic narrative, technical notes, or gallery exhibition commentary text blocks here...
        MARKDOWN

        File.write(md_path, scaffold)
        true
      end
      
      # @return [Hash] intermediate symbol-keyed exif metrics database extract
      def extract_exif_metadata(album_path, tif_files)
        catalog = {}
        return catalog if tif_files.empty?

        # 1. Construct the fast batch JSON stream command for ExifTool CLI
        # 2. Extract strictly required fields to keep allocation memory footprint minimal
        cmd = [
          "exiftool", "-json",
          "-DateTimeOriginal", "-Title", "-Description",
          File.join(album_path, "*.{tif,tiff,TIF,TIFF}")
        ]

        # Read the raw shell buffer using standard ruby json library block wrapper
        require 'json'
        raw_json = IO.popen(cmd, "r") { it.read }
        return catalog if raw_json.to_s.empty?

        # Parse the JSON payload stream and enforce strict symbol keys conventions
        raw_array = JSON.parse(raw_json, symbolize_names: true)
        return catalog unless raw_array.is_a?(Array)

        # Map external system headers directly into internal domain catalog metrics
        raw_array.each do |file_meta|
          next unless file_meta[:SourceFile]
          
          filename = File.basename(file_meta[:SourceFile])
          img_key = File.basename(filename, ".*").to_sym

          catalog[img_key] = {
            exif_title:       file_meta[:Title],
            exif_description: file_meta[:Description],
            exif_time:        file_meta[:DateTimeOriginal]
          }
        end

        catalog
      rescue StandardError => e
        puts "[Warning] Failed to extract EXIF metrics via ExifTool CLI: #{e.message}"
        catalog
      end
    end
  end
end
