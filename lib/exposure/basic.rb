require_relative 'basic/time_extentions'

module Exposure
  # Centralized structural and primitive helpers module mapping tools
  module Basic

    protected

    # @param hash [Object] raw configurations data to deep symbolize
    # @return [Object] standardized parameters with symbol keys
    def symbolize_keys(hash)
      case hash
      when Hash
        hash.each_with_object({}) do |(k, v), h|
          h[k.to_sym] = symbolize_keys(v)
        end
      when Array
        hash.map { |it| symbolize_keys(it) }
      else
        hash
      end
    end
  end
end
