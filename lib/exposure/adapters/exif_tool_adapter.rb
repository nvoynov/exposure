# lib/exposure/adapters/exif_tool_adapter.rb
require 'json'
require_relative '../ports/exif_metadata'

module Exposure
  module Adapters

    # Infrastructure adapter executing native ExifTool CLI batch processing streams
    class ExifToolAdapter < Ports::ExifMetadata
      # @see Exposure::Ports::ExifMetadata#extract
      def extract(album_path, filenames)
        catalog = {}
        return catalog if filenames.to_a.empty?

        # Batch query matching files inside target directory bounds efficiently
        cmd = [
          "exiftool", "-json",
          "-DateTimeOriginal", "-Title", "-Description",
          File.join(album_path, "*.{tif,tiff,TIF,TIFF}")
        ]

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
