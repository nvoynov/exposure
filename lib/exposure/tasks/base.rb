# lib/exposure/task/base.rb
require 'forwardable'
require_relative '../ports/adapters'
require_relative '../config'

module Exposure
  module Task
    # Base domain abstraction layer proxying external infrastructure gates.
    # Inheriting interactors gain implicit decoupled access to frozen ports.
    class Base
      class << self
        extend Forwardable

        # Direct class-level proxy routing capability configuration hooks
        def_delegators :'Exposure::Ports::Adapters',
                       :exif_metadata,
                       :image_transformation
      end

      extend Forwardable

      # Direct instance-level proxy routing for inline use inside use cases
      def_delegators :'Exposure::Ports::Adapters',
                     :exif_metadata,
                     :image_transformation
    end
  end
end

