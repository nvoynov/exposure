require_relative '../basic'

module Exposure
  module Builder

    # Abstract baseline builder providing recursive keys normalization
    class Base
      include Exposure::Basic # Fixed: Pulls clean shared symbolize_keys helper
    end
  end
end
