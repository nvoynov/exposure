# lib/exposure/model/gallery.rb
require_relative 'base'

module Exposure
  module Model

    # Top-level domain collection aggregate grouping and ranking albums lists data matrix
    class Gallery < Base

      # @param albums [Array<Album>] raw collection pool of aggregate album nodes
      def initialize(albums:)
        @albums = albums

        # Enforce read-only state across the root presentation block
        freeze
      end

      # @return [Array<Album>] sorted dynamically by the latest album image timestamp, freshest goes first
      # Leverages Ruby 3.4 implicit local block argument mapping parameter 'it'
      def albums
        @albums
          .sort_by { it.last_image.created_at }
          .reverse
      end
    end
  end
end
