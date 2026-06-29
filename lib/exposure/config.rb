require 'yaml'
require 'singleton'
require 'forwardable'
require_relative 'config_data'

module Exposure

  # Infrastructure proxy Singleton managing the active configuration state
  class Config
    include ::Singleton
    extend ::Forwardable

    CONFIG_FILE = "local_config.yml"

    # Forward all configuration attributes readers straight to the internal data object
    def_delegators :@data, :gallery_path, :max_short_side, :unsharp_enabled,
                           :unsharp_spec, :supported_formats, :default_album_keywords,
                           :default_image_keywords, :default_genre, :default_location,
                           :album_manifesto_guideline, :watermark_path,
                           :blank_holder_path

    def initialize
      # Start with a pristine fallback default dataset
      @data = ConfigData.new
    end
    
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
