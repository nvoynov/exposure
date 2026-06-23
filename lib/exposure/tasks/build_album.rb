require 'date'
require_relative '../model'
require_relative '../config'
require_relative '../builder'
require_relative '../presenter'

module Exposure
  module Task

    class BuildAlbum
      MD_LEDGER  = "ALBUM.md"
      YML_LEDGER = "ALBUM.yml"

      def initialize(metadata_port:)
        raise ArgumentError, "Missing required metadata_port!" unless metadata_port
        @metadata_port = metadata_port
      end

      # @param album_path [String] path to a specific album directory
      # @return [Model::Album] compiled, synchronized, read-only domain aggregate
      def call(album_path)
        dirname = File.basename(album_path)
        formats = Exposure::Config.instance.supported_formats
        
        master_files = Dir
          .glob(File.join(album_path, "*.{#{formats}}"))
          .map { File.basename(it) }

        return nil if master_files.empty?

        # 1. Scrap reference files straight from disk Footprints
        exif_catalog = @metadata_port.extract(album_path, master_files)
        fresh_images = build_fresh_images_pool(dirname, master_files, exif_catalog)
        
        reference_album = Builder::Album.new.call(dirname: dirname, fresh_images: fresh_images)

        # 2. Materialize author edits if files exist
        md_path  = File.join(album_path, MD_LEDGER)
        yml_path = File.join(album_path, YML_LEDGER)

        saved_album = 
          if File.exist?(md_path) && File.exist?(yml_path)
            Builder::UserAlbum.new.call(
              md_content: File.read(md_path), yml_content: File.read(yml_path), dirname: dirname
            )
          else
            nil
          end

        # 3. Securely calculate the consolidated result inside Domain Layer object
        final_album = reference_album.merge(saved_album)

        # 4. Dump clean flat updates back to author environment files
        payload = Presenter::UserAlbum.new.call(final_album)
        File.write(md_path, payload[:md_content])
        File.write(yml_path, payload[:yml_content])

        final_album
      end

      private

      # Inside lib/exposure/tasks/build_album.rb -> def build_fresh_images_pool

      def build_fresh_images_pool(dirname, master_files, exif_catalog)
        config = Exposure::Config.instance
        
        sorted_files = master_files.sort_by do |f|
          exif_catalog[File.basename(f, ".*").to_sym]&.[](:exif_time) || ""
        end

        sorted_files.map do |f|
          img_key = File.basename(f, ".*")
          meta = exif_catalog[img_key.to_sym] || {}
          file_route = File.join(config.gallery_path, dirname, f)
          
          parsed_time = 
            if meta[:exif_time]
              # Explicitly format the strict ExifTool colon-separated schema using DateTime
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
