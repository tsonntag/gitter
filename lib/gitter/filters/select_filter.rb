module Gitter

  class SelectFilter < AbstractFilter

    attr_reader :filters

    def initialize grid, name, filters, opts = {} 
      super grid, name, opts
      @filters = filters.inject({}){|memo,filter| memo[filter.name] = filter; memo}
      if @input_options 
        @input_options = {}
        @input_options[:collection] = @filters.keys
      end
    end

    def apply driver, *args
      if filter = @filters[:"#{args.first}"]
        filter.apply driver
      else
        driver
      end
    end

    def counts driver = nil
      @filters.values.inject({}) do |memo,filter|
        count = filter.counts[true]
        memo[filter.name] = count if count > 0
        memo
      end
    end

    def distinct_values driver = nil
      @distinct_values ||= @filters.keys.map
    end
  end

end
