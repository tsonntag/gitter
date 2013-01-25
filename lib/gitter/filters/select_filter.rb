module Gitter

  class SelectFilter < AbstractFilter

    attr_reader :filters, :values

    def initialize grid, name, filters, opts = {} 
      super grid, name, opts
      @filters = filters.inject({}){|memo,filter| memo[filter.name] = filter; memo}
      @values = opts[:values]
      if @input_options == true
        @input_options = {}
        @input_options[:collection] = @filters.keys
      end
    end

    def apply driver, value 
      if filter = @filters[value]
        filter.apply driver
      else
        driver
      end
    end

    def counts driver = nil
      values_names = Hash === values ? values.keys : values
      @filters.values.inject({}) do |memo,filter|
        if !values_names || values_names.include?(filter.name)
          count = filter.counts[true]
          memo[filter.name] = count if count > 0
        end
        memo
      end
    end

    # returns map { :name => label }
    def distinct_values driver = nil
      @distinct_values ||= values || @filters.values.inject({}){|memo, filter| memo[filter.name] = filter.label; memo }
    end

  end

end
