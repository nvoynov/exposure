# lib/exposure/tasks/build_gallery.rb
require_relative '../model'
require_relative 'base'
require_relative 'build_album'

module Exposure
  module Task

    # Application business rule orchestrating the global gallery creation stream
    class BuildGallery < Base
      
      # Setup pristine orchestrator state without direct architecture coupling
      def initialize
        # Intentionally empty: port adapters are resolved dynamically via Base
      end

      # @return [Model::Gallery] compiled and sorted immutable gallery instance
      # @raise [RuntimeError] if configuration path or target albums are missing
      def call
        gallery_path = Exposure::Config.instance.gallery_path
        raise "Gallery configuration path is empty!" if gallery_path.to_s.empty?

        album_dirs = Dir
          .children(gallery_path)
          .map { File.join(gallery_path, it) }
          .select { File.directory?(it) }

        raise "No albums found in the specified gallery path!" if album_dirs.empty?

        album_builder = BuildAlbum.new
        albums_pool = album_dirs.map { album_builder.call(it) }

        Model::Gallery.new(albums: albums_pool)
      end
    end
  end
end
