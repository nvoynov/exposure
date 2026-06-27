require_relative '../test_helper.rb'

module Dummy
  extend self

  def make_image(filename:, title: "", description: "", keywords: "raw", created_at: Time.now)
    Exposure::Model::Image.new(
      filename: filename,
      title: title,
      description: description,
      keywords: keywords,
      genre: "Street",
      location: "Kyiv",
      created_at: created_at
    )
  end

  def make_album(dirname: "gallery", story: "", images: [], keywords: ["art"])
    Exposure::Model::Album.new(
      dirname: dirname,
      slug: dirname.downcase,
      title: dirname.capitalize,
      description: "Default description",
      story: story,
      keywords: keywords,
      genre: "Fine Art",
      location: "Ukraine",
      cover: images.first&.filename || "",
      images: images,
      hidden: false
    )
  end
end
