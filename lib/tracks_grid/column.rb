module TracksGrid

  class Column

    attr_reader :name, :header, :order_desc

    def initialize( name, opts = {}, &block )
      @name = name
      @header = opts.delete(:header){name}
      @order = opts.delete(:order)
      @order_desc = opts.delete(:order_desc){"#{@order} desc"}
      @block = block
    end

    def order( desc = false )
      desc ? order_desc : @order 
    end

    def apply( model )
      if @block
        @block.call model
      else
        model.send :name
      end
    end
  end

end
