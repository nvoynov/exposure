require 'fileutils'
require_relative 'build_gallery'
require_relative 'build_site_album'

module Exposure
  module Task

    # High-level pipeline orchestrator managing the Jekyll site compile sequence
    class BuildSite
      
      # @param transform_port [Ports::ImageTransformation] image pipeline port
      # @param metadata_port [Ports::ExifMetadata] metadata extraction port
      def initialize(transform_port:, metadata_port:)
        raise ArgumentError, "Missing required transform_port!" unless transform_port
        raise ArgumentError, "Missing required metadata_port!" unless metadata_port
        
        @transform_port = transform_port
        @metadata_port  = metadata_port
      end

def call(target_site_path)
        gallery_builder = BuildGallery.new(metadata_port: @metadata_port)
        gallery_entity  = gallery_builder.call

        assets_dest_root = File.join(target_site_path, "assets", "gallery")
        all_generated_thumbs = []

        album_pipeline = BuildSiteAlbum.new(transform_port: @transform_port)
        
        gallery_entity.albums.each do |album|
          local_thumbs = 
            album_pipeline.call(album, target_site_path, assets_dest_root)
          all_generated_thumbs += local_thumbs
        end

        # 3. Assemble global main wall Open Graph cover collage grid matrix
        config = Exposure::Config.instance
        og_cover_dest = File.join(assets_dest_root, "og_cover.jpg")
        
        # Sample unique images up to 5 entries
        base_samples = all_generated_thumbs.uniq.first(5)
        
        # Guarantee exactly 5 inputs by plugging the baseline blank holder
        while base_samples.size < 5
          base_samples << config.blank_holder_path
        end

        @transform_port.create_exhibition_wall(
          images: base_samples,
          compiled_wm: config.compiled_watermark_path,
          output: og_cover_dest
        )
      end
    end
  end
end
