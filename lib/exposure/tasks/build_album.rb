# lib/exposure/tasks/build_album.rb
require 'date'
require_relative 'base'
require_relative '../model'
require_relative '../builder'
require_relative '../presenter'

module Exposure
  module Task

    # Core use-case compiling, synchronizing and merging album data from disk
    class BuildAlbum < Base
      MD_LEDGER  = "ALBUM.md"
      YML_LEDGER = "ALBUM.yml"

      def initialize
        # Intentionally empty: port adapters are resolved dynamically via Base
      end

      # @param album_path [String] path to a specific album directory
      # @return [Model::Album, nil] read-only consolidated domain aggregate
      def call(album_path)
        dirname = File.basename(album_path)
        formats = Exposure::Config.instance.supported_formats
        
        master_files = Dir
          .glob(File.join(album_path, "*.{#{formats}}"))
          .map { File.basename(it) }

        return nil if master_files.empty?

        # 1. Scrap reference files straight from disk footprints via decoupled port
        exif_catalog = exif_metadata.extract(album_path, master_files)
        fresh_images = build_fresh_images_pool(dirname, master_files, exif_catalog)
        
        reference_album = Builder::Album.new.call(
          dirname: dirname, fresh_images: fresh_images
        )

        # 2. Materialize author edits if state metadata files exist
        md_path  = File.join(album_path, MD_LEDGER)
        yml_path = File.join(album_path, YML_LEDGER)

        saved_album = 
          if File.exist?(md_path) && File.exist?(yml_path)
            Builder::UserAlbum.new.call(
              md_content:  File.read(md_path), 
              yml_content: File.read(yml_path), 
              dirname:     dirname
            )
          end

        # 3. Securely calculate the consolidated result inside domain model
        final_album = reference_album.merge(saved_album)

        # 4. Dump clean flat updates back to author environment files
        payload = Presenter::UserAlbum.new.call(final_album)
        
        # FIXED: Only trigger physical disk writes if text content actually changed
        write_if_changed(md_path, payload[:md_content])
        write_if_changed(yml_path, payload[:yml_content])

        final_album
      end

      private

      def write_if_changed(path, content)
        if File.exist?(path)
          return if File.read(path) == content
        end
        File.write(path, content)
      end

      # Compiles raw metadata fields into structured immutable image models pool
      def build_fresh_images_pool(dirname, master_files, exif_catalog)
        config = Exposure::Config.instance
        
        sorted_files = master_files.sort_by do
          exif_catalog[File.basename(it, ".*").to_sym]&.[](:exif_time) || ""
        end

        sorted_files.map do |f|
          img_key = File.basename(f, ".*")
          meta = exif_catalog[img_key.to_sym] || {}
          file_route = File.join(config.gallery_path, dirname, f)
          
          parsed_time = 
            if meta[:exif_time]
              # Explicitly format the strict ExifTool colon-separated schema
              DateTime.strptime(meta[:exif_time], "%Y:%m:%d %H:%M:%S").to_time
            else
              File.mtime(file_route)
            end

          Model::Image.new(
            filename:    f, 
            title:       "", 
            description: meta[:exif_description] || "",
            keywords:    config.default_image_keywords, 
            genre:       "", 
            location:    "", 
            created_at:  parsed_time
          )
        end
      end
    end
  end
end
