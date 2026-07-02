require 'delegate'
require_relative 'site_album'

module Exposure
  module Decorator

    # Presentation decorator augmenting the global Gallery model with Jekyll rules
    class SiteGallery < SimpleDelegator
      # @return [Array<SiteAlbum>] chronologically sorted collection of decorated albums
      def sorted_albums
        albums.map { SiteAlbum.new(_1) }.sort_by do |decorated_album|
          latest_photo = decorated_album.images.max_by(&:created_at)
          latest_photo ? latest_photo.created_at.to_i : 0
        end.reverse
      end
    end
  end
end
