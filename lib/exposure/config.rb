require 'yaml'

module Exposure

  # Configuration holder
  class Config
    CONFIG_FILE = "local_config.yml"

    attr_reader :gallery_path

    def initialize(gallery_path:)
      @gallery_path = gallery_path
    end

    # @return [Config, nil] returns the loaded Config instance using strict symbol keys parsing
    def self.read
      return nil unless File.exist?(CONFIG_FILE)

      # 1. Load the raw file using modern standard YAML compilation options
      # 2. Convert keys to symbols if necessary to fulfill Rule #1 constraints
      raw_data = YAML.load_file(CONFIG_FILE)
      return nil unless raw_data.is_a?(Hash)

      # Ensure keys are localized as symbols safely
      config_data = raw_data.transform_keys(&:to_sym)
      return nil unless config_data[:gallery_path]

      new(gallery_path: config_data[:gallery_path])
    end

    # @return [TrueClass, FalseClass] confirms storage state transaction execution status
    def save
      return false if @gallery_path.to_s.empty?

      # Explicitly payload block using native Ruby 3+ symbol dictionary serialization format
      payload = { gallery_path: @gallery_path }
      File.write(CONFIG_FILE, YAML.dump(payload))
      true
    end
  end
end
