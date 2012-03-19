  class AbstractFilter

    attr_reader :grid, :name, :input_options, :input_tag, :formatter, :find_format, :order

    def initialize grid, name, opts ={}
       @grid, @name = grid, name
       @label = opts[:label]
       @input_options = opts[:input]
       @input_tag = opts[:input_tag]
       @include_blank = opts[:include_blank]
       
       @exact = opts.fetch(:exact){true}
       @ignore_case = opts.fetch(:ignore_case){false}
       @formatter = opts[:formatter]
       @find_format = opts[:find_format]
       @param_scoped = opts.fetch(:param_scoped){true}
       @order = opts.fetch(:order)

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

    def param_scoped?
      @param_scoped
    end

    def selected_value
      @selected_value ||= grid.filter_value name
    end

    def selected?
      selected_value.present?
    end

    def counts driver = grid.filtered_driver
      { true => apply(driver.unordered).count }
    end

    def distinct_values driver = nil
      [ true, false ]
    end

    def input_tag
      return '' unless input?

      @input_tag ||= if col = collection
        col = [''] + col if include_blank? && col.size > 1
        select_tag col
      else
        text_field_tag
      end
    end

    def text_field_tag
      @text_field_tag ||= h.text_field_tag scoped_name, grid.params[name.intern], :class => 'grid'
    end

    def select_tag collection 
      h.select_tag scoped_name, h.options_for_select(collection, grid.params[name.intern]), :class => 'grid'
    end

    def format value
      case formatter
      when Hash then formatter[value]
      when Proc then formatter.call value
      else value;
      end
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
