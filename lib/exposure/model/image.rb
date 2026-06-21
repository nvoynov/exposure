require_relative 'base'
require_relative 'titled_tagged'

module Exposure
  module Model

    # Pure domain class representing an immutable fine-art photographic print record
    class Image < Base
      include TitledTagged

      # @!attribute [r] filename
      #   @return [String] unique asset target filename slug (e.g., "frame_01.webp")
      attr_reader :filename

      # @!attribute [r] created_at
      #   @return [Time] clean domain chronological metric representation
      attr_reader :created_at

      # @param filename [String] target asset filename slug
      # @param title [String] artistic name or fallback designation
      # @param description [String] editorial text notes or stories
      # @param tags [Array<String>] search keywords semantic index
      # @param created_at [Time] clean domain chronological metric representation
      def initialize(filename:, title:, description:, tags:, created_at:)
        @filename = filename
        @title = title
        @description = description
        @tags = tags
        @created_at = created_at

        # Enforce strict domain immutability layer to prevent state mutations
        freeze
      end
    end
  end
end
