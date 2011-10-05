module TracksGrid

  class FacetValue

    attr_reader :facet, :value, :count

    def initialize( facet, value, count )
      @facet, @value, @count = facet, value, count 
    end

    def filter_params
      { name => value }
    end

    def name
      facet.name
    end

    def to_s
      "#{name}:#{value}=#{count}"
    end
  end

  class Facet

    attr_reader :filter, :scope

    def initialize( filter, scope )
      @filter, @scope = filter, scope
    end

    def values
      values = [] 
      filter.counts(scope).each do |value, count|
        values << FacetValue.new(self, value, count)
      end
      values
    end

    def name
      filter.name
    end

    def label
      filter.label
    end

    def to_s
      "#{self.class}(#{name},label=#{label})"
    end

  end

end
