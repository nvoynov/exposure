module Exposure
  module Ports

    # Abstract interface boundary for metadata extraction subsystems
    class ExifMetadata
      # @param album_path [String] target album directory route context
      # @param filenames [Array<String>] collection list of master files to scan
      # @return [Hash] standardized symbol-keyed inner engine metadata structure
      def extract(album_path, filenames)
        raise NotImplementedError, "#{self.class} must implement #extract"
      end
    end
  end
end
