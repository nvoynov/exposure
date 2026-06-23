require 'yaml'

module Exposure
  module Presenter

    # Compiles the final monolithic release Markdown page for Jekyll consumption
    class SiteAlbum < Base

      # @param decorated_album [Decorator::SiteAlbum] presentation decorated album instance
      # @return [String] monolithic formatted text content file stream with Front Matter
      def call(decorated_album)
        # Strip any existing old author Pandoc title lines from the raw story text
        story_body = 
          decorated_album.story.lines.reject { |l| l.start_with?("%") }.join.strip

        front_matter = {
          "layout"         => "series",
          "title"          => decorated_album.title,
          "slug"           => decorated_album.slug,
          "cover"          => "#{File.basename(decorated_album.cover, '.*')}.webp",
          "image"          => decorated_album.og_cover_path,
          "photos"         => decorated_album.photos_payload,
          "preview_photos" => decorated_album.preview_photos_payload
        }

        # Transform keys to strings to prevent symbol points insertion
        human_meta = front_matter.transform_keys(&:to_s)

        "#{YAML.dump(human_meta)}---\n\n#{story_body}\n"
      end
    end
  end
end
