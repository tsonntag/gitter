module TracksGrid
  class Filter
    
    attr_reader :grid, :desc
    delegate :name, :to => :desc
    
    def initialize( grid, desc )
      @grid, @desc = grid, desc
    end
    
    def label
      @label ||= desc.label or I18n.translate "tracksgrid.#{grid.name}.filters.#{name}", :default => name.humanize       
    end
    
    def counts
      desc.counts grid
    end

    def input_tag
      return '' unless input? 

      @input_tag ||= desc.input_tag || if col = collection 
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
      desc.input_options.respond_to?(:[]) && desc.input_options[:collection]
    end
    
    
  end
end
