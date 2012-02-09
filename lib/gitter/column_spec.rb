module Gitter

  class ColumnSpec

    attr_reader :name, :header_specs, :attr, :block, :order, :order_desc

    def initialize( name, opts = {}, &block )
      @name = name
      @header_specs = [opts[:header] || opts[:headers]].flatten.compact.map do |content|
        HeaderSpec.new name, content, :column_spec => self
      end
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
