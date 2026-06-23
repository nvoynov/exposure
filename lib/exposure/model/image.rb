require_relative 'base'
require_relative 'description'

module Exposure
  module Model

    # Pure domain class representing an immutable fine-art photographic record
    class Image < Base
      include Description

      # @!attribute [r] filename
      #   @return [String] unique asset target filename slug
      attr_reader :filename

      # @!attribute [r] created_at
      #   @return [Time] clean domain chronological metric representation
      attr_reader :created_at

      def initialize(filename:, title:, description:, keywords:, genre:,
                     location:, created_at:)
        @filename    = filename
        @title       = title
        @description = description
        @keywords    = keywords
        @genre       = genre
        @location    = location
        @created_at  = created_at

        freeze
      end

    end
  end
end
