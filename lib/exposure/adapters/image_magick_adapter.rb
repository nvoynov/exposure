require_relative '../ports/image_transformation'
require_relative '../config'

module Exposure
  module Adapters

    # Infrastructure adapter executing native ImageMagick CLI conversion streams
    class ImageMagickAdapter < Ports::ImageTransformation

      def initialize
        # Verify if the target binary is installed and executable in the system
        unless system("command -v magick >/dev/null 2>&1")
          raise RuntimeError, "ImageMagick CLI dependency is missing in this OS!"
        end
      end
      
      # @see Exposure::Ports::ImageTransformation#convert_to_full
      def convert_to_full(source:, destination:)
        # SMART CACHE GUARD: Skip optimization if the converted asset is up to date
        if File.exist?(destination) && File.mtime(source) <= File.mtime(destination)
          return true
        end

        config = Exposure::Config.instance
        dimensions = IO.popen(
          ["magick", "identify", "-format", "%w %h", source], "r"
        ) { it.read }
        
        width, height = dimensions.to_s.split.map(&:to_i)
        return false if width.to_i.zero? || height.to_i.zero?

        short_side = [width, height].min
        cmd = ["magick", source]

        if short_side > config.max_short_side
          cmd += ["-resize", "#{config.max_short_side}x#{config.max_short_side}^>"]
        end

        if config.unsharp_enabled && !config.unsharp_spec.empty?
          cmd += ["-unsharp", config.unsharp_spec]
        end

        cmd += ["-quality", "82", destination]
        system(*cmd)
      end

      # @see Exposure::Ports::ImageTransformation#convert_to_thumbnail
      def convert_to_thumbnail(source:, destination:)
        # SMART CACHE GUARD: Skip preview generation if it is already actualized
        if File.exist?(destination) && File.mtime(source) <= File.mtime(destination)
          return true
        end

        cmd = ["magick", source, "-resize", "600x400>", "-quality", "75", destination]
        system(*cmd)
      end

      # @see Exposure::Ports::ImageTransformation#montage
      def montage(sources:, destination:)
        return false if sources.to_a.size < 4

        # Pure pixel-grid stitching using basic conversion append operators.
        # This completely guarantees no FreeType or font engines are triggered.
        cmd = [
          "magick",
          "(", sources[0], sources[1], "+append", ")", # Glue top row horizontally
          "(", sources[2], sources[3], "+append", ")", # Glue bottom row horizontally
          "-append",                                   # Stack both rows vertically
          "-resize", "1200x800",
          "-quality", "85",
          destination
        ]
        system(*cmd)
      end

    end
  end
end
