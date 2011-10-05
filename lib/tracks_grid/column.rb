module TracksGrid

  class Column

    attr_reader :name, :header, :order_desc

    def initialize( name, opts = {}, block )
      @name = name
      @header = opts.delete(:header){name.to_s.humanize}
      @order = opts.delete(:order){name.to_s}
      @order_desc = opts.delete(:order_desc){"#{@order} DESC"}
      @block = block
    end

    def ordered( scope, desc = false )
      scope.order order(desc)
    end

    def apply( model )
      #puts "apply #{self.inspect}"
      if @block
        @block.call model
      else
        model.send name
      end
    end

    private

    def order( desc = false )
      desc ? order_desc : @order 
    end


  end

end
