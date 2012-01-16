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

    def apply( driver, *args )
      if spec = @filter_specs[:"#{args.first}"]
        spec.apply driver
      else
        driver
      end
    end

    def counts( driver )
      @filter_specs.values.inject({}) do |memo,spec|
        count = spec.apply(driver).count
        memo[spec.name] = count if count > 0
        memo
      end
    end
  end

end
