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

      # Generates an optimized, highly compressed global gallery overview canvas.
      # Uses web-safe sampling factors and compression levels to optimize payload weight.
      #
      # @param images [Array<String>] Paths to exactly 5 input pictures
      # @param compiled_wm [String] Path to the pre-rendered compiled PNG watermark
      # @param output [String] Target location path for the output file
      # @return [void]
      # @raise [ArgumentError] if the source array pool size is incorrect
      # @raise [ProcessingError] if the underlying ImageMagick CLI execution fails
      def create_exhibition_wall(images:, compiled_wm:, output:)
        raise ArgumentError, 'Requires exactly 5 images' if images.length != 5
      end
        
      # Generates an optimized, highly compressed scattered print simulation deck.
      # Uses web-safe sampling factors and compression levels to optimize payload weight.
      #
      # @param images [Array<String>] Paths to exactly 5 input pictures
      # @param compiled_wm [String] Path to the pre-rendered compiled PNG watermark
      # @param output [String] Target location path for the output file
      # @return [void]
      # @raise [ArgumentError] if the source array pool size is incorrect
      # @raise [ProcessingError] if the underlying ImageMagick CLI execution fails
      def create_scattered_portfolio(images:, compiled_wm:, output:)
        raise ArgumentError, 'Requires exactly 5 images' if images.length != 5
      end
    end
  end
end
