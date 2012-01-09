module TracksGrid

  class Column

    attr_reader :spec, :grid

    delegate :name, :to => :spec
    delegate :params, :view_context, :to => :grid

    def initialize( spec, grid )
      @spec, @grid = spec, grid
    end

    def cell( model )
      if spec.block
        Decorator.decorate model, :h => view_context
        model.instance_eval &block
      else
        model.send name
      end
    end

    def header
      case spec.header
      when Proc
        if view_context 
          Struct.new(:h).new(view_context).instance_eval &spec.header
        else
          spec.header.call
        end
      else
        spec.header
      end
    end

    # if current params contain order for this column then revert direction 
    # else add order_params for this column to current params
    def order_params
      p = params.dup
      if ordered?
        p[:desc] = !desc?
      else
        p = p.merge :order => name, :desc => false 
      end
      p
    end

    def desc?
      to_boolean params[:desc]
    end

    def ordered?
      params[:order] == name.to_s
    end

    private

    def to_boolean(s)
      not (s && s.match(/true|t|1$/i)).nil?
    end
  end

end
