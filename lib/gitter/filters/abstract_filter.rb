  class AbstractFilter

    attr_reader :grid, :name, :input_options, :input_tag, :format

    def initialize grid, name, opts ={}
       @name = name
       @label = opts[:label]
       @input_options = opts[:input]
       @input_tag = opts[:input_tag]
       @include_blank = opts[:include_blank]
       
       @exact = opts.fetch(:exact){true}
       @ignore_case = opts.fetch(:ignore_case){false}
       @format = opts[:format]

       # replace shortcut
       if coll = opts[:input_collection]
         (@input_options||={})[:collection] = coll
       end
    end

    def label
      @label ||= grid.translate(:filters, name)
    end

    def input?
      @input_options || @input_tag
    end

    def include_blank?
      @include_blank
    end

    def counts 
      { true => apply(grid.driver.unordered).count }
    end

    def distinct_values 
      [ true, false ]       
    end

    def input_tag
      return '' unless input?

      @input_tag ||= if col = collection
        data = grid.eval(col)
        data = [''] + data if include_blank?
        select_tag
      else
        text_field_tag
      end
    end

    def text_field_tag
      filter_name = name
      tag_name = scoped_name
      @text_field_tag ||= h.text_field_tag tag_name, h.params[filter_name], :class => 'grid'
    end

    def select_tag collection 
      filter_name = name
      tag_name = scoped_name
      h.select_tag tag_name, h.options_for_select(collection, h.params[filter_name]), :class => 'grid'
    end

    private
    def scoped_name
      "#{grid.key}[#{name}]"
    end

    def collection
      input_options.respond_to?(:[]) && input_options[:collection]
    end

    def exact opts = {}
      opts.fetch(:exact){@exact}
    end

    def ignore_case opts = {}
      opts.fetch(:ignore_case){@ignore_case}
    end

    def h
      @h ||= grid.h
    end

end
