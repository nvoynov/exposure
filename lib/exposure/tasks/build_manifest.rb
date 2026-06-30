# lib/exposure/tasks/build_manifest.rb
require 'json'
require 'fileutils'
require_relative 'base'

module Exposure
  module Task

    # Domain use-case responsible for compiling the PWA client-side cache manifest.
    # Scans the final built production asset tree and versions files dynamically.
    class BuildManifest < Base

      def initialize
        # Intentionally clean: reads configurations lazily through Base port
      end

      # @param target_site_path [String] destination root folder inside Jekyll
      # @return [void]
      def call(target_site_path)
        assets_dir = File.join(target_site_path, "assets", "gallery")
        manifest_path = File.join(target_site_path, "assets-manifest.json")

        # Graceful exit guard if the asset directory has not been populated yet
        return unless File.directory?(assets_dir)

        # 1. Generate an un-hashed global build version based on UTC timestamp
        manifest_payload = {
          "version" => Time.now.utc.strftime("%Y%m%d-%H%M%S"),
          "assets"  => {}
        }

        # 2. Recursively crawl the output gallery folder for compiled imagery sheets
        search_pattern = File.join(assets_dir, "**", "*.{webp,jpg,jpeg,png}")
        
        Dir.glob(search_pattern).sort.each do |file_path|
          next unless File.file?(file_path)

          # Extract cleanly the relative path from the site directory baseline
          # Example: "site/assets/gallery/svalovichi/full/image.webp" -> "/assets/gallery/svalovichi/full/image.webp"
          clean_key = file_path.sub(target_site_path, "").gsub(%r{\A/?}, "/")
          
          # Inject immutable modification timestamp footprint as asset version
          manifest_payload["assets"][clean_key] = File.mtime(file_path).to_i.to_s
        end

        # 3. Serialize and dump payload using clean minimized JSON formatting
        FileUtils.mkdir_p(File.dirname(manifest_path))
        File.write(manifest_path, JSON.fast_generate(manifest_payload))
      end
    end
  end
end
