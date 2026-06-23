require 'yaml'
require 'singleton'
require 'forwardable'
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
  end

  # Infrastructure proxy Singleton managing the active configuration state
  class Config
    include ::Singleton
    extend ::Forwardable

    CONFIG_FILE = "local_config.yml"

    # Forward all configuration attributes readers straight to the internal data object
    def_delegators :@data, :gallery_path, :max_short_side, :unsharp_enabled,
                           :unsharp_spec, :supported_formats, :default_album_keywords,
                           :default_image_keywords, :default_genre, :default_location

    def initialize
      # Start with a pristine fallback default dataset
      @data = ConfigData.new
    end

    # @return [Config] loads and synchronizes the active instance context state
# Inside lib/exposure/config.rb -> class Config block context

    # @return [Config] loads and synchronizes the active instance context state
    def self.read
      if File.exist?(CONFIG_FILE)
        raw_data = YAML.load_file(CONFIG_FILE)
        if raw_data.is_a?(Hash)
          # Efficiently transform plain string keys straight into Symbols
          clean_meta = raw_data.transform_keys(&:to_sym)
          
          # Safely overwrite the data pointer without initialization conflicts
          instance.instance_variable_set(:@data, ConfigData.new(**clean_meta))
        end
      end
      instance
    end

    # @param path [String] absolute route to the target photography root
    # @return [Config] returns the synchronized singular instance profile
    def self.update_gallery_path(path)
      # Re-materialize the immutable data object with the updated path value
      updated_data = 
        instance.instance_variable_get(:@data).with(gallery_path: path.to_s)
        
      instance.instance_variable_set(:@data, updated_data)
      instance.save
      instance
    end

    # @return [TrueClass, FalseClass] confirms serialization disk transaction status
    def save
      return false if gallery_path.to_s.empty?

      # Leverage ConfigData's inherited Base to_h method effortlessly
      plain_payload = @data.to_h.transform_keys(&:to_s)
      
      File.write(CONFIG_FILE, YAML.dump(plain_payload))
      true
    end
  end
end
