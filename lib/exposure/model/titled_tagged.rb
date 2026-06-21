module Exposure
  module Model

    # Shared semantic attributes layer for fine-art exhibition entities
    module TitledTagged
      # @!attribute [r] title
      #   @return [String] the artistic title or layout identifier
      attr_reader :title

      # @!attribute [r] description
      #   @return [String] custom editorial text notes or caption commentary
      attr_reader :description

      # @!attribute [r] tags
      #   @return [Array<String>] semantic search keywords dictionary index
      attr_reader :tags
    end
  end
end
