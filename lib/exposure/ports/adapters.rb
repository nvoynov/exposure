# lib/exposure/ports/adapters.rb
require 'forwardable'

module Exposure
  module Ports

    # Static infrastructure gate holding boot-time frozen system adapters.
    # Acts as a centralized service registry under Hexagonal architecture.
    class Adapters
      class << self
        extend Forwardable

        # Proxy calls directly to the internal immutable instance variables
        def_delegators :@instance, :exif_metadata, :image_transformation

        # Boot-time dependency injection engine setup gate.
        # Once initialized, the global infrastructure layer is frozen forever.
        #
        # @param container [#metadata_port, #image_transformation] frozen maps
        # @return [void]
        # @raise [StandardError] if the application state context is already frozen
        def setup(container)
          raise 'Domain adapters are already frozen!' if @instance

          @instance = container
          @instance.freeze
        end
      end
    end
  end
end

