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

      # @param target_site_path [String] destination root inside Jekyll structure
      def call(target_site_path)
        # 1. Trigger domain tree serialization matrix directly
        gallery_builder = BuildGallery.new(metadata_port: @metadata_port)
        gallery_entity  = gallery_builder.call

        assets_dest_root = File.join(target_site_path, "assets", "gallery")
        all_generated_thumbs = []

        # 2. Instantiate and delegate individual album workflows downward
        album_pipeline = BuildSiteAlbum.new(transform_port: @transform_port)
        
        gallery_entity.albums.each do |album|
          # Collect generated slices references back into the global pool
          local_thumbs = 
            album_pipeline.call(album, target_site_path, assets_dest_root)
          
          all_generated_thumbs += local_thumbs
        end

        # 3. Assemble global main wall Open Graph cover collage grid matrix
        if all_generated_thumbs.size >= 4
          og_cover_dest = File.join(assets_dest_root, "og_cover.jpg")
          sampled_thumbs = all_generated_thumbs.sample(4)
          @transform_port.montage(sources: sampled_thumbs, destination: og_cover_dest)
        end
      end
    end
  end
end
