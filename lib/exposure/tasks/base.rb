# lib/exposure/task/base.rb
require 'forwardable'
require_relative '../ports'
require_relative '../config'

module Exposure
  module Task

    # Base domain abstraction layer proxying external infrastructure gates.
    # Inheriting interactors gain implicit decoupled access to frozen ports.
    class Base
      class << self
        # Syntactic sugar shortcut instantiation gate matching Ruby 3.4 guidelines.
        # Spawns a pristine stateless instance and forwards all input signals seamlessly.
        def call(*args, **kwargs, &block)
          new.call(*args, **kwargs, &block)
        end
      end

      extend Forwardable

      # Direct instance-level proxy routing for inline use inside use cases
      # UPDATED: Delegates directly to the new Ports::Context execution layer
      def_delegators :'Exposure::Ports::Context',
                     :exif_metadata,
                     :image_transformation,
                     :logger
    end
  end
end
