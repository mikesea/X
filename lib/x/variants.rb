module X
  module Variants
    def variants
      @variants ||= []
    end

    def variant(name, weight: nil, default: false)
      add_variant Variant.new(name: name, weight: weight, default: default)
    end

    private

      def add_variant(variant)
        @variants ||= []
        @variants << variant
      end
  end
end
