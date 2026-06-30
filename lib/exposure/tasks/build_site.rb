require 'fileutils'
require_relative 'base'
require_relative 'build_gallery'
require_relative 'build_site_album'
require_relative 'build_manifest'

module Exposure
  module Task

    # High-level pipeline orchestrator managing the Jekyll site compile sequence
    class BuildSite < Base
      
      # Setup pristine orchestrator state without injecting explicit adapters
      def initialize
        # Intentionally empty: adapters are resolved through transparent DI ports
      end

      # @param target_site_path [String] destination root inside Jekyll structure
      # @return [void]
      def call(target_site_path)
        # 1. Trigger domain tree serialization matrix using explicit decoupled port
        gallery_builder = BuildGallery.new
        gallery_entity  = gallery_builder.call

        assets_dest_root = File.join(target_site_path, "assets", "gallery")
        all_generated_thumbs = []

        # 2. Instantiate and delegate individual album workflows downward cleanly
        album_pipeline = BuildSiteAlbum.new
        
        gallery_entity.albums.each do |album|
          # Collect generated slices references back into the global pool
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

        # Invokes the decoupled proxy port seamlessly
        image_transformation.create_exhibition_wall(
          images: base_samples,
          compiled_wm: config.watermark_path,
          output: og_cover_dest
        )
        
        # FINAL PASS: Compile the immutable PWA client asset manifest map
        BuildManifest.new.call(target_site_path)
      end
    end
  end
end
