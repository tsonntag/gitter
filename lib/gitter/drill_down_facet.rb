module Gitter

  class DrillDownFacet < Facet

    attr_reader :params

    def initialize filter, params
      super filter
      @params = params
    end

    def to_s
      "#{self.class}(#{name},label=#{label})"
    end
  end

end
