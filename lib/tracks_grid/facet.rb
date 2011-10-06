module TracksGrid

  class FacetValue

    attr_reader :facet, :value, :count
    delegate :name, :to => :facet

    def initialize( facet, value, count )
      @facet, @value, @count = facet, value, count 
    end

    def filter_params
      { name => value }
    end

    def to_s
      "#{name}:#{value}=#{count}"
    end
  end

  class Facet

    attr_reader :filter, :scope
    delegate :name, :label, :to => :filter

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

    def to_s
      "#{self.class}(#{name},label=#{label})"
    end

  end

end
