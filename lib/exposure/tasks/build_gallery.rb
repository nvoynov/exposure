# lib/exposure/tasks/build_gallery.rb
require_relative '../model'
require_relative '../config'
require_relative 'build_album'

module Exposure
  module Task

    # Application business rule orchestrating the global gallery creation stream
    class BuildGallery
      
      # @param metadata_port [Ports::ExifMetadata] strict abstraction port tool
      def initialize(metadata_port:)
        raise ArgumentError, "Missing required metadata_port!" unless metadata_port
        @metadata_port = metadata_port
      end

      # @return [Model::Gallery] compiled and sorted immutable gallery instance
      def call
        # Pull the global baseline photography path straight from the Singleton
        gallery_path = Exposure::Config.instance.gallery_path
        raise "Gallery configuration path is empty!" if gallery_path.to_s.empty?

        album_dirs = Dir
          .children(gallery_path)
          .map { File.join(gallery_path, it) }
          .select { File.directory?(it) }

        raise "No albums found in the specified gallery path!" if album_dirs.empty?

        album_builder = BuildAlbum.new(metadata_port: @metadata_port)
        albums_pool = album_dirs.map { album_builder.call(it) }

        Model::Gallery.new(albums: albums_pool)
      end
    end
  end
end
