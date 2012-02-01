module Gitter

  class ColumnSpec

    attr_reader :name, :header, :attr, :block

    def initialize( name, opts = {}, &block )
      @name = name
      @header = opts[:header] 
      @attr = opts[:column] 
      @order = case opts[:order] 
        when true then name
        when String, Symbol then opts[:order]
        else nil
      end
      @order_desc = opts[:order_desc]
      @block = block 
    end

    def ordered( driver, desc = false )
      order_desc = case desc
        when String then desc
        when true then @order_desc || true
        else false
      end
      puts "OOOOOOOOOO #{self.name}, order_desc=#{order_desc}, ordered?= #{ordered?}"
      if ordered?
        driver.order @order, order_desc
      else
        driver
      end
    end

    def ordered?
      !!@order
    end

  end

end
