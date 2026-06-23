# lib/exposure/decorator/site_album.rb
require 'delegate'

module Exposure
  module Decorator

    # Presentation decorator augmenting the Album model with Jekyll-specific features
    class SiteAlbum < SimpleDelegator
      
      # @return [Array<String>] clean array of keywords split for search optimization
      def keywords
        super.to_s.split(/,\s*/).map(&:strip).reject(&:empty?)
      end

      # @return [String] relative absolute path route to the Facebook OG matrix preview image
      def og_cover_path
        "/assets/gallery/#{slug}/og_album_cover.jpg"
      end

      # @return [Array<Hash>] web-optimized photos collection array for Jekyll template layout
      def photos_payload
        images.map do |img|
          clean_name = File.basename(img.filename, '.*')
          {
            "filename"    => "#{clean_name}.webp",
            "thumbnail"   => "#{clean_name}_thumb.webp",
            "title"       => img.title,
            "description" => img.description,
            "keywords"    => img.keywords.to_s.split(/,\s*/).map(&:strip).reject(&:empty?),
            "genre"       => img.genre,
            "location"    => img.location
          }
        end
      end

      # @return [Array<Hash>] samples exactly 5 previews, padding with holders if pool is low
      def preview_photos_payload
        payload = photos_payload.sample(5)
        while payload.size < 5
          payload << { "filename" => "blank_holder.webp", "is_placeholder" => true }
        end
        payload
      end
    end
  end
end
