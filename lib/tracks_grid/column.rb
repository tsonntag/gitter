module TracksGrid

  class Column

    attr_reader, :name, :header, :order_desc

    def initialize( name, *opts = {}, &block )
      @name = name
      @header = opts[header] || name
      @order = opts[:order]
      @order_desc = opts[:order_desc]{"#{@order} desc"}
      @block = block
    end

    def order( desc = false )
      desc ? order_desc : @order 
    end

    def apply( model )
      if @block
        block.call model
      else
        model.send :name
      end
    end
  end

end
