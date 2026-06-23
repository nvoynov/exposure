require_relative 'base'

module Exposure
  module Builder

    # Materializes a pure reference Album domain aggregate straight from disk
    class Album < Base

      # @param dirname [String] baseline origin folder name on disk
      # @param fresh_images [Array<Model::Image>] images harvested from disk/EXIF
      # @return [Model::Album] clean reference domain aggregate instance
      def call(dirname:, fresh_images:)
        config = Exposure::Config.instance

        Model::Album.new(
          dirname:     dirname,
          slug:        dirname.downcase,
          title:       dirname.capitalize.gsub('_', ' '),
          description: "A fine-art photographic series exploration.",
          story:       "Write your creative narrative manifesto here...",
          keywords:    config.default_album_keywords,
          genre:       config.default_genre,
          location:    config.default_location,
          cover:       fresh_images.first&.filename || "",
          images:      fresh_images,
          hidden:      false
        )
      end

    end
  end
end
