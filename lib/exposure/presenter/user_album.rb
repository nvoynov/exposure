require_relative 'base'

module Exposure
  module Presenter

    # Presents the Album model into twin human-editable author configuration files
    class UserAlbum < Base

      # Centralized presentation guideline embedded directly as HTML comment
      GUIDELINE = <<~HTML.freeze
        <!--
        # -------------------------------------------------------------------
        # ARTIST MANIFESTO WORKSPACE
        # -------------------------------------------------------------------
        # Write your extensive creative narrative, exhibition background,
        # or standalone conceptual photography stories in the text area below.
        # To configure individual photo captions, use the ALBUM.yml file.
        # -------------------------------------------------------------------
        -->
      HTML

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
        story_body = album.story.lines.reject { |l| l.start_with?("%") }.join.strip
        human_md_meta = md_meta.transform_keys(&:to_s)

        {
          md_content:  "#{YAML.dump(human_md_meta)}---\n\n#{GUIDELINE}\n#{story_body}\n",
          yml_content: YAML.dump({ "images" => formatted_images })
        }
      end
    end
  end
end
