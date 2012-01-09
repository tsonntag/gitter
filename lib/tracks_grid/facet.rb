module TracksGrid

  class FacetData
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

    def data
      @data ||= begin
        filter.counts(scope).map do |value, count|
          FacetData.new(self, value, count)
        end
      end
    end

    def to_s
      "#{self.class}(#{name},label=#{label})"
    end
  end

end
