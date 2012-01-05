module TracksGrid

  class SelectFilter < AbstractFilter

    attr_reader :filters

    def initialize( name, filters, options )
      super name, options
      @filters = filters.inject({}){|memo,filter| memo[filter.name] = filter; memo}
      case @input_options 
      when true, :collection
        @input_options = {}
        @input_options[:collection] = [''] + @filters.keys 
      end
    end

    def apply( scope, *args )
      if filter = @filters[:"#{args.first}"]
        filter.apply scope
      else
        scope
      end
    end

    def counts( scope )
      @filters.values.inject({}) do |memo,filter|
        memo[filter.name] = filter.apply(scope).count
        memo
      end
    end
  end

end
