module TracksGrid

  class Column
    attr_reader :desc, :grid

    def initialize( grid, desc )
      @grid, @desc = grid, desc
    end

    def name
      desc.name
    end

    def params
      grid.params
    end

    def cell( model )
      if desc.block
        grid.eval desc.block, model
      else
        model.send name
      end
    end

    def ordered
      desc.ordered grid.driver, params[:desc]
    end

    def header
      @header ||= case desc.header
      when false then ''
      when nil then
        I18n.translate "tracksgrid.#{grid.name}.headers.#{name}", :default => name.to_s.humanize
      else
        grid.eval desc.header
      end
    end

    # if current params contain order for this column then revert direction 
    # else add order_params for this column to current params
    def order_params
      @order_params ||= begin
        p = params.dup
        if ordered?
          p[:desc] = !desc?
        else
          p = p.merge :order => name, :desc => false 
        end
        p
      end
    end

    def desc?
      @desc ||= to_boolean params[:desc]
    end

    def ordered?
      @ordered ||= params[:order] == name.to_s
    end

    def link( opts = {} )
      if desc.ordered?
        direction = ordered? ? (desc? ? '^' : 'v') : ''
        grid.h.link_to (direction + header), order_params.merge(opts)
      else
        header 
      end 
    end

    private

    def order_img
      "#{TracksGrid::ASSETS}/images/sort_#{desc? ? 'asc' : 'desc'}.gif"
    end

    def order_img_tag
      ordered ? grid.h.image_tag(order_img) : ''
    end

    def to_boolean(s)
      not (s && s.match(/true|t|1$/i)).nil?
    end
  end

end
