require 'forwardable'
require_relative 'base'
require_relative 'titled_tagged'

module Exposure
  module Model

    # Domain aggregate class maintaining execution rules over an image collection
    class Album < Base
      include TitledTagged
      extend Forwardable
      def_delegator :@images, :last, :last_image

      # @!attribute [r] images
      #   @return [Array<Image>] ordered timeline sequence array of image entities
      attr_reader :images

      # @param dirname [String] raw source directory identity slug name on disk
      # @param title [String] artistic name or fallback designation
      # @param description [String] short editorial text summary notes
      # @param story [String] extensive creative narrative or standalone exhibition story
      # @param tags [Array<String>] search keywords semantic index
      # @param cover [String] target filename representing the primary cover asset
      # @param images [Array<Image>] ordered timeline sequence array of image entities
      # @param hidden [TrueClass, FalseClass] visibility privacy flag indicator
      def initialize(dirname:, title:, description:, story:, tags:, cover:, images:, hidden:)
        @dirname = dirname
        @title = title
        @description = description
        @story = story
        @tags = tags
        @cover = cover
        @images = images
        @hidden = hidden

        # Lock the aggregate layout state permanently against downstream side-effects
        freeze
      end

      # Ruby 3.4 shorthand end-line syntax expression definition format
      def hidden? = @hidden == true
    end
  end
end
