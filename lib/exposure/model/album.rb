# lib/exposure/model/album.rb
require 'forwardable'
require_relative 'base'
require_relative 'description'

module Exposure
  module Model

    # Domain aggregate class maintaining execution rules over an image collection
    class Album < Base
      include Description
      extend Forwardable

      def_delegator :@images, :last, :last_image

      # @!attribute [r] images
      #   @return [Array<Image>] ordered timeline sequence array of image entities
      attr_reader :images

      # @!attribute [r] dirname
      #   @return [String] raw source directory identity slug name on disk
      attr_reader :dirname

      # @!attribute [r] story
      #   @return [String] extensive creative narrative text content
      attr_reader :story

      # @!attribute [r] cover
      #   @return [String] target filename representing the primary cover asset
      attr_reader :cover
  
      # @!attribute [r] slug
      #   @return [String]
      attr_reader :slug
  
      # @!attribute [r] hidden
      #   @return [String]
      attr_reader :hidden

      def initialize(dirname:, slug:, title:, description:, story:, keywords:, genre:,
                     location:, cover:, images:, hidden:)
        @dirname     = dirname
        @slug        = slug
        @title       = title
        @description = description
        @story       = story
        @keywords    = keywords
        @genre       = genre
        @location    = location
        @cover       = cover
        @images      = images
        @hidden      = hidden

        freeze
      end

      def hidden? = @hidden == true

      # @param saved [Model::Album, nil] author's manually curated metadata state
      # @return [Model::Album] consolidated resulting immutable domain aggregate
      def merge(saved)
        return self if saved.nil?

        current_filenames = @images.map(&:filename)
        saved_filenames   = saved.images.map(&:filename)
        
        # Keep author's custom storyboard sequence but append brand new disk files
        orphans = current_filenames - saved_filenames
        final_sequence = saved_filenames + orphans

        merged_images = final_sequence.map do |fname|
          fresh_img = @images.find { |it| it.filename == fname }
          saved_img = saved.images.find { |it| it.filename == fname }

          if fresh_img.nil?
            nil # Drop the asset if it was physically deleted from the drive
          elsif saved_img.nil?
            fresh_img # Add new discovered file straight from disk
          else
            # Prioritize author's manual text parameters over raw file defaults
            Model::Image.new(
              filename:    fname,
              title:       saved_img.title || fresh_img.title,
              description: saved_img.description || fresh_img.description,
              keywords:    saved_img.keywords || fresh_img.keywords,
              genre:       saved_img.genre || fresh_img.genre,
              location:    saved_img.location || fresh_img.location,
              created_at:  fresh_img.created_at
            )
          end
        end.compact

        # Synthesize a single finalized aggregate, preserving author edits
        Album.new(
          dirname:     @dirname,
          slug:        saved.slug || @slug,
          title:       saved.title || @title,
          description: saved.description || @description,
          story:       saved.story.empty? ? @story : saved.story,
          keywords:    saved.keywords.empty? ? @keywords : saved.keywords,
          genre:       saved.genre || @genre,
          location:    saved.location || @location,
          cover:       saved.cover || @cover,
          images:      merged_images,
          hidden:      saved.hidden == true
        )
      end

    end
  end
end
