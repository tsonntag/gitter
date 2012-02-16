module Gitter

  class ColumnSpec

    attr_reader :name, :header_specs, :attr, :block, :order, :order_desc

    def initialize( name, opts = {}, &block )
      @name = name
      if header_opts = opts[:header] || opts[:headers]
         @header_specs = [header_opts].flatten.map do |header_spec|
           case header_spec
           when Hash
             content = header_spec.delete(:content)
             opts = header_spec
           else
             content = header_spec
             opts = {}
            end
          HeaderSpec.new name, content, opts.merge(:column_spec => self)
        end
      else
        @header_specs = [HeaderSpec.new(name, nil, opts.merge(:column_spec => self))]
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

    def to_s
      "ColumnSpec(#{name},ordered=#{ordered?},#{header_specs.size} headers)"
    end
  end

end
