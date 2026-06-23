module Exposure
  module Model

    # Core semantic descriptor metadata for fine-art photography assets
    module Description
      # @!attribute [r] title
      #   @return [String] the artistic title or layout identifier
      attr_reader :title

      # @!attribute [r] description
      #   @return [String] custom editorial text notes or caption commentary
      attr_reader :description

      # @!attribute [r] keywords
      #   @return [String] human-written flat string of comma-separated keywords
      attr_reader :keywords

      # @!attribute [r] genre
      #   @return [String] photography genre classification (e.g., "landscape")
      attr_reader :genre

      # @!attribute [r] location
      #   @return [String] geographical context location (e.g., "Kyiv, Ukraine")
      attr_reader :location
    end
  end
end
