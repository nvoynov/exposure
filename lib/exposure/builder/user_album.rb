# lib/exposure/builder/user_album.rb
require 'yaml'
require_relative 'base'

module Exposure
  module Builder

    # Re-materializes a curated Album domain aggregate out of author files
    class UserAlbum < Base

      # @param md_content [String] raw textual data content from ALBUM.md
      # @param yml_content [String] raw textual data content from ALBUM.yml
      # @param dirname [String] baseline origin folder name on disk
      # @return [Model::Album] metadata-populated domain aggregate instance
      def call(md_content:, yml_content:, dirname:)
        md_parts = md_content.split("---")
        md_meta = md_parts.size >= 3 ? YAML.safe_load(md_parts[1]) : {}
        story_body = parse_story_body(md_parts, md_content)

        yml_meta = yml_content.to_s.strip.empty? ? {} : YAML.safe_load(yml_content)
        meta = symbolize_keys(md_meta.merge(yml_meta))

        raw_images = meta[:images] || []
        
        # Leverages true Ruby 3.4 'it' block shorthand variable mapping
        storyboard_files = meta[:storyboard] || raw_images.map { it[:filename] }

        ordered_images = storyboard_files.map do |filename|
          # Leverages true Ruby 3.4 'it' block shorthand variable searching
          img_hash = raw_images.find { it[:filename] == filename } || {}

          Model::Image.new(
            filename:    filename,
            title:       img_hash[:title] || "", # Fixed: Keep title empty to protect minimalist passport
            description: img_hash[:description] || "",
            keywords:    img_hash[:keywords].to_s,
            genre:       img_hash[:genre] || "",
            location:    img_hash[:location] || "",
            created_at:  img_hash[:created_at] ? Time.iso8601(img_hash[:created_at].to_s) : Time.now
          )
        end.compact

        Model::Album.new(
          dirname:     dirname,
          slug:        meta[:slug] || dirname.downcase,
          title:       meta[:title],
          description: meta[:description],
          story:       story_body,
          keywords:    meta[:keywords].to_s,
          genre:       meta[:genre],
          location:    meta[:location],
          cover:       meta[:cover],
          images:      ordered_images,
          hidden:      meta[:hidden] == true
        )
      end

      private

      def parse_story_body(md_parts, md_content)
        if md_parts.size >= 3
          md_parts[2..].join("---").strip
        else
          md_content.strip
        end
      end
    end
  end
end
