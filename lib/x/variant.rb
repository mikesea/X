module X
  class Variant
    attr_reader :name, :weight, :default

    def initialize(name:, weight: nil, default: false)
      @name     = name
      @weight   = weight
      @default  = default
    end
  end
end
