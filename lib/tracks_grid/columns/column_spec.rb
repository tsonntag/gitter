module TracksGrid

  class ColumnSpec

    attr_reader :name, :header, :block

    def initialize( name, opts = {}, &block )
      @name = name
      @header = case opts[:header] 
        when false then ''
        when nil then  name.to_s.humanize
        else opts[:header] 
      end
      @order = case opts[:order] 
      when true then name.to_s
      when String, Symbol then opts[:order]
      end
      @order_desc = opts[:order_desc] || "#{@order} DESC"
      @block = block 
    end

    def ordered( scope, desc = false )
      if ordered?
        scope.order(desc ? @order_desc : @order)
      else
        scope
      end
    end

    def ordered?
      !!@order
    end

  end

end
