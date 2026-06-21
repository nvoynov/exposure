# lib/exposure/tasks/build_gallery.rb
require_relative '../model'
require_relative 'build_album'

module Exposure
  module Task

    # Application business rule orchestrating the global gallery creation stream
    class BuildGallery
      
      # @param metadata_port [Ports::ExifMetadata] strict abstraction boundary tool
      def initialize(metadata_port:)
        raise ArgumentError, "Missing required metadata_port!" unless metadata_port
        
        @metadata_port = metadata_port
      end

      # @param gallery_path [String] path to the root source photography directory
      # @return [Model::Gallery] compiled and sorted immutable gallery domain instance
      def call(gallery_path)
        album_dirs = Dir
          .children(gallery_path)
          .map { File.join(gallery_path, it) }
          .select { File.directory?(it) }

        raise "No albums found in the specified gallery path!" if album_dirs.empty?

        # Secure dependency injection drill-down flow
        album_builder = BuildAlbum.new(metadata_port: @metadata_port)
        albums_pool = album_dirs.map { album_builder.call(it) }

        Model::Gallery.new(albums: albums_pool)
      end
    end
  end
end
