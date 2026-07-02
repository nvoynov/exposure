# lib/exposure/tasks/build_site.rb
require 'fileutils'
require_relative 'base'
require_relative 'build_gallery'
require_relative 'build_site_album'
require_relative 'build_manifest'
require_relative '../decorator/site_gallery'
require_relative '../config'

module Exposure
  module Task
    class BuildSite < Base
      def initialize; end

      # @param target_site_path [String] destination root inside Jekyll structure
      # @return [void]
      def call(target_site_path)
        raw_gallery     = BuildGallery.call
        site_gallery    = Decorator::SiteGallery.new(raw_gallery)
        assets_dest_root = File.join(target_site_path, "assets", "gallery")
        
        # GARBAGE COLLECTION PASS: Purge legacy or removed slugs footprints
        active_slugs = site_gallery.sorted_albums.map(&:slug)
        garbage_collect_outdated_slugs(target_site_path, assets_dest_root, active_slugs)

        all_generated_thumbs = []
        album_pipeline = BuildSiteAlbum.new
        
        # Each with index to inject a strict chronological weight parameter
        site_gallery.sorted_albums.each_with_index do |web_album, index|
          logger.info("Sequence Mapping: #{web_album.title} (Slug: #{web_album.slug})")

          # Pass index + 1 (1, 2, 3...) downward to mark the sequence order
          local_thumbs = album_pipeline.call(
            web_album, target_site_path, assets_dest_root, index + 1
          )
          all_generated_thumbs += local_thumbs
        end

        config = Exposure::Config.instance
        og_cover_dest = File.join(assets_dest_root, "og_cover.jpg")
        base_samples = all_generated_thumbs.uniq.first(5)
        
        while base_samples.size < 5
          base_samples << config.blank_holder_path
        end

        image_transformation.create_exhibition_wall(
          images: base_samples,
          compiled_wm: config.watermark_path,
          output: og_cover_dest
        )

        BuildManifest.call(target_site_path)
      end

      private

      def garbage_collect_outdated_slugs(site_path, assets_root, active_slugs)
        series_dir = File.join(site_path, "_series")
        
        if File.directory?(series_dir)
          Dir.glob(File.join(series_dir, "*.md")).each do |md_file|
            file_slug = File.basename(md_file, ".md")
            unless active_slugs.include?(file_slug)
              logger.info("[GC] Evicting outdated series ledger: #{File.basename(md_file)}")
              FileUtils.rm_f(md_file)
            end
          end
        end

        if File.directory?(assets_root)
          Dir.children(assets_root).each do |child|
            child_path = File.join(assets_root, child)
            next unless File.directory?(child_path)
            next if %w[full thumbs].include?(child) 

            unless active_slugs.include?(child)
              logger.info("[GC] Evicting orphaned media folder: #{child}")
              FileUtils.rm_rf(child_path)
            end
          end
        end
      end
    end
  end
end
