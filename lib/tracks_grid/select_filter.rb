module TracksGrid

  class SelectFilter < AbstractFilter

    attr_reader :filters

    def initialize( name, filters, options )
      @filters = filters.inject({}){|memo,filter| memo[filter.name] = filter; memo}
      super name, options
    end

    def apply( scope, *args )
      if filter = @filters[args.first]
        filter.apply scope
      else
        scope
      end
    end

    def counts( scope )
      @filters.values.inject({}) do |memo,filter|
        memo[filter.label] = filter.apply(scope).count
        memo
      end
    end
  end

end
