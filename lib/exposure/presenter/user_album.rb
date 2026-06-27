# lib/exposure/presenter/user_album.rb
# frozen_string_literal: true

require_relative 'base'

module Exposure
  module Presenter

    # Presents the Album model into twin human-editable author configuration files
    class UserAlbum < Base

      # @param album [Model::Album] immutable domain aggregate instance
      # @return [Hash<Symbol, String>] serialized contents for MD and YML files
      def call(album)
        raw = to_h(album)
        images = raw[:images] || []

        # 1. Slice and construct the artist manifesto front matter metadata
        md_meta = raw.slice(:title, :cover, :description, :genre, :location)
        md_meta[:keywords]   = Array(raw[:keywords]).join(", ")
        md_meta[:storyboard] = images.map { |it| it[:filename] }

        # 2. Re-map internal collection into a pure flat array of simple hashes
        formatted_images = images.map do |img|
          img_meta = img.slice(:filename, :title, :description, :genre, :location)
          img_meta[:keywords] = Array(img[:keywords]).join(", ")
          img_meta.transform_keys(&:to_s)
        end

        # Strip any existing old title headers from the raw story body text
        story_body = album.story.to_s.lines.reject { |l| l.start_with?("%") }.join.strip
        human_md_meta = md_meta.transform_keys(&:to_s)

        # Grab the centrally configured guideline string from Config instance
        guideline = Exposure::Config.instance.album_manifesto_guideline

        # If the author haven't written anything yet, provide the template
        final_story = story_body.empty? ? guideline.strip : story_body

        {
          md_content:  "#{YAML.dump(human_md_meta)}---\n\n#{final_story}\n",
          yml_content: YAML.dump({ "images" => formatted_images })
        }
      end
    end
  end
end
