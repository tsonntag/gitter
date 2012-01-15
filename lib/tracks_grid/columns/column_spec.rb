module TracksGrid

  class ColumnSpec

    attr_reader :name, :header, :block

    def initialize( name, opts = {}, &block )
      @name = name
      @header = opts[:header] 
      @order = case opts[:order] 
      when true then name.to_s
      when String, Symbol then opts[:order]
      end
      @desc = opts[:order_desc]
      @block = block 
    end

    def ordered( driver, desc = false )
      if ordered?
        driver.order @order, @desc
      else
        driver
      end
    end

    def ordered?
      !!@order
    end

  end

end
