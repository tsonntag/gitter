  class AbstractFilter

    attr_reader :grid, :name, :input_options, :input_tag, :formatter, :order, :label

    def initialize grid, name, opts = {}
       @grid, @name = grid, name
       @label = opts.delete(:label){grid.translate(:filters, name)}
       @input_options = opts.delete(:input){nil}
       @input_tag = opts.delete(:input_tag){nil}
       @include_blank = opts.delete(:include_blank){false}
       
       @formatter = opts.delete(:formatter){nil}
       @param_scoped = opts.delete(:param_scoped){true}
       @order = opts.delete(:order){nil}

       # replace shortcut
       if coll = opts.delete(:input_collection){nil}
         (@input_options||={})[:collection] = coll
       end
       @opts = opts
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
      @text_field_tag ||= h.text_field_tag scoped_name, grid.params[name.intern], 
        class: "grid grid-#{name}"
    end

    def select_tag collection 
      h.select_tag scoped_name, h.options_for_select(collection, grid.params[name.intern]), 
        class: "grid grid-#{name}"
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

    def h
      @h ||= grid.h
    end

    def sort_hash hash
      hash.keys.sort.inject({}){|memo,k|memo[k] = hash[k]; memo}
    end
end
