# lib/exposure/adapters/exif_tool_adapter.rb
require 'json'
require_relative '../ports/exif_metadata'

module Exposure
  module Adapters

    # Infrastructure adapter executing native ExifTool CLI batch processing streams
    class ExifToolAdapter < Ports::ExifMetadata

      def initialize
        # Verify if the target binary is installed and executable in the system
        unless system("command -v exiftool >/dev/null 2>&1")
          raise RuntimeError, "ExifTool CLI dependency is missing in this OS!"
        end
      end

      # @see Exposure::Ports::ExifMetadata#extract
      def extract(album_path, filenames)
        catalog = {}
        return catalog if filenames.to_a.empty?

        # 1. Extract and split the formats string from singleton config safely
        formats = Exposure::Config.instance.supported_formats.split(',')

        # 2. Build explicit separate -ext flags for each format to satisfy ExifTool
        ext_flags = formats.flat_map { ["-ext", it] }

        # 3. Construct the clean execution array matrix avoiding shell expansion bugs
        cmd = [
          "exiftool", "-json",
          "-DateTimeOriginal", "-Title", "-Description"
        ] + ext_flags + [album_path]

        raw_json = IO.popen(cmd, "r") { it.read }
        return catalog if raw_json.to_s.empty?

        raw_array = JSON.parse(raw_json, symbolize_names: true)
        return catalog unless raw_array.is_a?(Array)

        raw_array.each do |file_meta|
          next unless file_meta[:SourceFile]

          fname = File.basename(file_meta[:SourceFile])
          img_key = File.basename(fname, ".*").to_sym

          catalog[img_key] = {
            exif_title:       file_meta[:Title],
            exif_description: file_meta[:Description],
            exif_time:        file_meta[:DateTimeOriginal]
          }
        end

        catalog
      rescue StandardError => e
        puts "[Warning] ExifToolAdapter pipeline failed: #{e.message}"
        catalog
      end

    end   
  end
end
