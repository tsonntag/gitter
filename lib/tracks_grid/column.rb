module TracksGrid

  class Column

    attr_reader :name, :header

    def initialize( name, opts = {}, &block )
      @name = name
      @header = opts[:header] || name.to_s.humanize
      @order = opts[:order] || name.to_s
      @order_desc = opts[:order_desc] || "#{@order} DESC"
      @block = block 
    end

    def ordered( scope, desc = false )
      scope.order order(desc)
    end

    def render( model, view_context )
      if @block
        Decorator.decorate model, :h => view_context
        model.instance_eval &@block
      else
        model.send name
      end
    end

    # Argument: params of current request
    # if current params contain order for this column then revert direction 
    # else add order_params for this column to current params
    def order_params(params={})
      p = params.symbolize_keys
      if ordered?(p)
        p[:desc] = !desc?(p)
      else
        p = p.merge :order => name, :desc => false 
      end
      p
    end

    def desc?(params)
      to_boolean params.symbolize_keys[:desc]
    end

    def ordered?(params)
      params.symbolize_keys[:order] == name.to_s
    end

    private

    def order( desc = false )
      desc ? @order_desc : @order 
    end

    def to_boolean(s)
      not (s && s.match(/true|t|1$/i)).nil?
    end
  end

end
