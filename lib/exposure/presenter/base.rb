module Exposure
  module Presenter

    # Abstract baseline presenter providing structural serialization for domains
    class Base
      protected

      # @param model [Model::Base] domain model instance to serialize
      # @param keys [Array<Symbol>] optional white-list filtering array
      # @return [Hash<String, Object>] plain string-keyed configuration hash
      def to_h(model, *keys)
        # 1. Harvest target keys strictly from the model initialization schema
        allowed_keys = model.class.constructor_keys
        target_keys = keys.empty? ? allowed_keys : allowed_keys & keys

        # 2. Map domain elements into clean string-keyed serialization targets
        target_keys.each_with_object({}) do |key, hash|
          val = model.public_send(key)
          
          # Process nested structures and collections recursively
          hash[key] = 
            case val
            when Model::Base
              to_h(val)
            when Array
              val.map { |it| it.is_a?(Model::Base) ? to_h(it) : it }
            else
              val
            end
        end
      end
    end
  end
end
