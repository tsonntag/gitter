module TracksGrid

  class SelectFilterSpec < AbstractFilterSpec

    attr_reader :filters

    def initialize( name, filter_specs, opts = {} )
      super name, opts
      @filter_specs = filter_specs.inject({}){|memo,spec| memo[spec.name] = spec; memo}
      case @input_options 
      when true, :collection
        @input_options = {}
        @input_options[:collection] = @filter_specs.keys 
      end
    end

    def apply( scope, *args )
      if spec = @filter_specs[:"#{args.first}"]
        spec.apply scope
      else
        scope
      end
    end

    def counts( scope )
      @filter_specs.values.inject({}) do |memo,spec|
        count = spec.apply(scope).count
        memo[spec.name] = count if count > 0
        memo
      end
    end
  end

end
