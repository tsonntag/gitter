module TracksGrid
  class Filter
    
    attr_reader :grid, :spec
    delegate :name, :to => :spec
    
    def initialize( grid, spec )
      @grid, @spec = grid, spec
    end
    
    def label
      spec.label or grid.translate(:filters, name)
    end

    def counts
      spec.counts grid
    end

    def input_tag
      return '' unless input? 

      @input_tag ||= spec.input_tag || if col = collection 
        select_tag [''] + grid.eval(col)
      else
        text_field_tag
      end
    end

    def text_field_tag
      @text_field_tag ||= grid.eval proc{ h.text_field_tag name, h.params[name], :class => 'grid'}
    end

    def select_tag( collection )
      grid.eval proc{ h.select_tag name, context.options_for_select(collection, h.params[name]), :class => 'grid'}
    end
 
    private
    def collection
      spec.input_options.respond_to?(:[]) && spec.input_options[:collection]
    end
    
  end
end
