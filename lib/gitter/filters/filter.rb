module Gitter
  class Filter
    
    attr_reader :grid, :spec
    delegate :name, :to => :spec
    
    def initialize( grid, spec )
      @grid, @spec = grid, spec
    end
    
    def label
      spec.label || grid.translate(:filters, name)
    end

    def counts
      spec.counts grid
    end

    def input_tag
      return '' unless spec.input? 

      @input_tag ||= spec.input_tag || if col = collection
        data = grid.eval(col)
        data = data.unshift ''if spec.include_blank?
        select_tag data
      else
        text_field_tag
      end
    end

    def text_field_tag
      filter_name = name
      @text_field_tag ||= grid.eval proc{ h.text_field_tag filter_name, h.params[filter_name], :class => 'grid'}
    end

    def select_tag( collection )
      filter_name = name
      grid.eval proc{ h.select_tag filter_name, h.options_for_select(collection, h.params[filter_name]), :class => 'grid' }
    end
 
    private
    def collection
      spec.input_options.respond_to?(:[]) && spec.input_options[:collection]
    end
    
  end
end
