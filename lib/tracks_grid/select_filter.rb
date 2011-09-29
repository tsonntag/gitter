module TracksGrid

  class SelectFilter < AbstractFilter

    attr_reader :filters

    def initialize( name, filters, options )
      @filters = filters.inject({}){|memo,filter| memo[filter.name] = filter; memo}
      super name, options
    end

    def apply( scope, value )
      if filter = @filters[value]
        filter.apply scope
      else
        scope
      end
    end

    def counts( scope )
      res = {}
      @filters.values.each do |filter|
        res[filter.label] = filter.apply(scope).count
      end
      res
    end
  end

end
