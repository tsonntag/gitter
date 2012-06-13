module Gitter

  class ColumnFilter < AbstractFilter

    attr_reader :columns

    def initialize grid, name, opts = {}
      @columns = [opts[:column]||opts[:columns]||name].flatten
      super
    end

    def apply driver, value = nil
      return driver if value.blank?

      attr_values = columns.inject({}){|memo,column| memo[column] = value; memo}
      driver.where attr_values, @opts
    end

    def counts driver = grid.filtered_driver
      if columns.size == 1
	sort_hash ordered(driver).group(columns.first).count
      else
        super
      end
    end

    def distinct_values driver = grid.filtered_driver
      if columns.size == 1
        ordered(driver).distinct_values(columns.first).sort
      else
        super
      end
    end

    private
    def ordered driver
      order_attr = case order
          when true then columns.first
	  when String, Symbol then order
	  else nil;
          end
      s = driver.unordered
      s = s.order(order_attr) if order_attr
      s
    end
  end

end 
