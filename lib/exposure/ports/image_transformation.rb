module Exposure
  module Ports

    # Abstract interface boundary for image manipulation engines
    class ImageTransformation
      # @param source [String] absolute path to the master photograph file
      # @param destination [String] target output path for the optimized WebP
      def convert_to_full(source:, destination:)
        raise NotImplementedError, "#{self.class} must implement #convert_to_full"
      end

      # @param source [String] absolute path to the master photograph file
      # @param destination [String] target output path for the preview asset
      def convert_to_thumbnail(source:, destination:)
        raise NotImplementedError, "#{self.class} must implement #convert_to_thumbnail"
      end

      # @param sources [Array<String>] collection of preview thumbnail paths
      # @param destination [String] target output path for the collage matrix
      def montage(sources:, destination:)
        raise NotImplementedError, "#{self.class} must implement #montage"
      end
    end
  end
end
