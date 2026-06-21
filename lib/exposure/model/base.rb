module Exposure
  module Model

    # Abstract baseline domain class providing universal serialization mechanics
    class Base
      # @return [Hash] dynamically maps internal instance states into a symbol-keyed catalog (Rule #1)
      def to_h
        instance_variables.each_with_object({}) do |var, hash|
          key = var.to_s.delete('@').to_sym
          value = instance_variable_get(var)

          # Safely unpack nested arrays of models using Ruby 3.4 'it' syntax
          hash[key] = value.is_a?(Array) ? value.map { it.respond_to?(:to_h) ? it.to_h : it } : value
        end
      end
    end
  end
end
