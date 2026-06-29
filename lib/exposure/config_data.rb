require_relative 'model/base'

module Exposure

  # Pure immutable domain data object holding configurations metrics
  class ConfigData < Model::Base
    # Static baseline system rollbacks for uninitialized variables
    DEFAULT_ALBUM_KEYWORDS = "series, art, photography"
    DEFAULT_IMAGE_KEYWORDS = "photography, frame"
    DEFAULT_GENRE          = "landscape"
    DEFAULT_LOCATION       = "Kyiv, Ukraine"

    # @!attribute [r] gallery_path
    #   @return [String] absolute or relative path to the photography root
    attr_reader :gallery_path

    # @!attribute [r] max_short_side
    #   @return [Integer] maximum bounding side boundary limit for web-rescale
    attr_reader :max_short_side

    # @!attribute [r] unsharp_enabled
    #   @return [TrueClass, FalseClass] unsharp mask filter activation status
    attr_reader :unsharp_enabled

    # @!attribute [r] unsharp_spec
    #   @return [String] raw ImageMagick command syntax specification
    attr_reader :unsharp_spec

    # @!attribute [r] supported_formats
    #   @return [String] comma-separated list of master formats
    attr_reader :supported_formats

    # @!attribute [r] default_album_keywords
    #   @return [String] fallback text keywords line for series
    attr_reader :default_album_keywords

    # @!attribute [r] default_image_keywords
    #   @return [String] fallback text keywords line for images
    attr_reader :default_image_keywords

    # @!attribute [r] default_genre
    #   @return [String] fallback primary photography genre classification
    attr_reader :default_genre

    # @!attribute [r] default_location
    #   @return [String] fallback primary geographical location context
    attr_reader :default_location

    def initialize(
      gallery_path: "", max_short_side: 1080, unsharp_enabled: true,
      unsharp_spec: "0x0.5+0.8+0.02", supported_formats: "tif,tiff,TIF,TIFF,jpg,jpeg,JPG,JPEG",
      default_album_keywords: DEFAULT_ALBUM_KEYWORDS, default_image_keywords: DEFAULT_IMAGE_KEYWORDS,
      default_genre: DEFAULT_GENRE, default_location: DEFAULT_LOCATION
    )
      @gallery_path           = gallery_path.to_s
      @max_short_side         = max_short_side.to_i
      @unsharp_enabled        = unsharp_enabled == true
      @unsharp_spec           = unsharp_spec.to_s
      @supported_formats      = supported_formats.to_s.gsub(/\s+/, "")
      @default_album_keywords = default_album_keywords.to_s
      @default_image_keywords = default_image_keywords.to_s
      @default_genre          = default_genre.to_s
      @default_location       = default_location.to_s
      freeze
    end
    
    def album_manifesto_guideline
      <<~HTML.freeze
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
    end

    # Returns the absolute path to the pre-rendered production PNG watermark
    # @return [String] absolute track to the identity asset file
    def watermark_path
      File.join(presets_dir, 'watermark.png')
    end

    # Returns the absolute path to the global backup blank placeholder image
    # @return [String] absolute route to the placeholder image asset
    def blank_holder_path
      File.join(presets_dir, 'blank_holder.webp')
    end

    private

    # Dynamically resolves the absolute path to the presets directory assets folder
    # @return [String] absolute root path to the assets directory presets
    def presets_dir
      File.expand_path('../assets/presets', __dir__)
    end
    
  end

end
