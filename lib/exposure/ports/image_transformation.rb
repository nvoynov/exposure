module Exposure
  module Ports

    # Abstract interface boundary for image manipulation and conversion engines
    class ImageTransformation
      # @param source [String] absolute path to master file
      # @param destination [String] target output path
      # @param geometry [String] ImageMagick geometry spec (e.g., "1920x1080>")
      # @param quality [Integer] compression quality metrics parameter (1..100)
      def resize(source:, destination:, geometry:, quality:)
        raise NotImplementedError, "#{self.class} must implement #resize"
      end
    end
  end
end
