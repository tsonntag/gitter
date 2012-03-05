module Gitter

  class Column

    attr_reader :grid, :name, :headers, :attr, :block, :order, :order_desc

    def initialize grid, name, opts = {}, &block
      @grid, @name = grid, name
      if opts.has_key?(:header) || opts.has_key?(:headers)  # handle :header => false correctly
         header_opts = opts.fetch(:header){opts.fetch(:headers)}
         @headers = [header_opts].flatten.map do |header_opt|
           case header_opt
           when Hash
             content = header_opt.delete(:content)
             h_opts = header_opt
           else
             content = header_opt
             h_opts = {}
           end
           Header.new grid, name, content, h_opts.merge(:column => self)
        end
      else
        @headers = [Header.new(grid, name, nil, opts.merge(:column => self))]
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

    def cell model
      if block
        grid.eval block, model
      else
        model.send(attr) 
      end 
    end

    def ordered
      d = grid.filtered_driver

      return d unless ordered? 

      desc = case params[:desc]
        when true, 'true' then order_desc || true
        when false, 'false' then false 
        else params[:desc]
      end

      if Proc === order
        arr = d.scope.map{|model| [model.instance_eval(&order),model]}
        d.new arr.sort{|a,b| (desc ? -1 : 1)*(a<=>b) }.map{|a|a[1]}
      else
        d.order order, desc
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

    def link label = nil, params = {}, opts = {}
      label ||= headers.first.label
      if @order
        img = order_img_tag(opts)
        label = h.content_tag :span, img + label if ordered?
        h.link_to label, grid.scoped_params(order_params.merge(params)), opts
      else
        label
      end
    end

    def to_s
      "Column(#{name},ordered=#{ordered?},#{headers.size} headers)"
    end

    private

    def order_img_tag opts = {}
      desc_img = opts.delete(:desc_img){'sort_desc.gif'}
      asc_img  = opts.delete(:asc_img){'sort_asc.gif'}
      h.image_tag( desc? ? desc_img : asc_img)
    end

    def h
     grid.h
    end

    def to_boolean s
      not (s && s.match(/true|t|1$/i)).nil?
    end

    def params
      grid.params
    end

  end

end
