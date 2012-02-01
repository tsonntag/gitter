module Gitter

  class ColumnSpec

    attr_reader :name, :header, :attr, :block, :order, :order_desc

    def initialize( name, opts = {}, &block )
      @name = name
      @header = opts[:header] 
      @attr = opts[:column] || name
      @order = case opts[:order] 
        when true then attr
        when false, nil then nil
        else opts[:order]
      end
      @order_desc = opts[:order_desc]
      @block = block 
    end

    def ordered?
      !!@order
    end

  end

end
