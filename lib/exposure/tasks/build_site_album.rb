# lib/exposure/tasks/build_site_album.rb
require 'fileutils'
require_relative 'base'
require_relative '../presenter'

module Exposure
  module Task
    class BuildSiteAlbum < Base
      def initialize
        @gallery_path = Exposure::Config.instance.gallery_path
      end

      def call(web_album, target_site_path, assets_dest_root, sequence_order = 0)
        album_local_thumbs = []

        jekyll_md_path = File.join(target_site_path, "_series", "#{web_album.slug}.md")
        FileUtils.mkdir_p(File.dirname(jekyll_md_path))
        
        meta_content = Presenter::SiteAlbum.new.call(web_album)
        fixed_payload = meta_content.sub("---\n", "---\norder: #{sequence_order}\n")
        File.write(jekyll_md_path, fixed_payload)

        album_dest_full   = File.join(assets_dest_root, web_album.slug, "full")
        album_dest_thumbs = File.join(assets_dest_root, web_album.slug, "thumbs")
        FileUtils.mkdir_p(album_dest_full)
        FileUtils.mkdir_p(album_dest_thumbs)

        # FIXED: Initialize tracking array
        active_output_names = []

        # Enforce explicit chronological order inside the album
        web_album.images.sort_by { _1.created_at.to_i }.each do |image|
          source_file_path = File.join(@gallery_path, web_album.dirname, image.filename)
          next unless File.exist?(source_file_path)

          clean_basename = File.basename(image.filename, '.*')
          full_out_name  = "#{clean_basename}.webp"
          thumb_out_name = "#{clean_basename}_thumb.webp"
          
          active_output_names << full_out_name
          active_output_names << thumb_out_name

          full_dest_path  = File.join(album_dest_full, full_out_name)
          thumb_dest_path = File.join(album_dest_thumbs, thumb_out_name)

          image_transformation.convert_to_full(source: source_file_path, destination: full_dest_path)
          image_transformation.convert_to_thumbnail(source: source_file_path, destination: thumb_dest_path)

          album_local_thumbs << thumb_dest_path
        end

        # INNER GARBAGE COLLECTION: Purge removed photos orphans from disk
        [album_dest_full, album_dest_thumbs].each do |dir|
          Dir.glob(File.join(dir, "*.webp")).each do |file|
            unless active_output_names.include?(File.basename(file))
              logger.info("[GC] Evicting orphaned asset: #{File.basename(file)}")
              FileUtils.rm_f(file)
            end
          end
        end

        config = Exposure::Config.instance
        album_cover_dest = File.join(assets_dest_root, web_album.slug, "og_album_cover.jpg")

        existing_thumbs_count = Dir.glob(File.join(album_dest_thumbs, "*.webp")).size
        collection_changed = web_album.images.size != existing_thumbs_count

        if !File.exist?(album_cover_dest) || collection_changed
          base_samples = album_local_thumbs.first(5)
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
