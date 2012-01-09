module TracksGrid

  class ColumnSpec

    attr_reader :name, :header, :block

    def initialize( name, opts = {}, &block )
      @name = name
      @header = opts[:header] || name.to_s.humanize
      @order = opts[:order] || name.to_s
      @order_desc = opts[:order_desc] || "#{@order} DESC"
      @block = block 
    end

    def ordered( scope, desc = false )
      scope.order(desc ? @order_desc : @order)
    end

  end

end
