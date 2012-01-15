module TracksGrid
  class Filter
    
    attr_reader :grid, :spec
    
    def initialize( grid, spec )
      @grid, @spec = grid, spec
    end
    
    def label
      @label ||= spec.label || I18n.translate "tracksgrid.#{grid.name}.filters.#{spec.name}", :default => spec.name.humanize       
    end
    
    def apply( *args )
      spec.apply grid.driver, *args
    end
     
    def count
      @count ||= grid.driver.count
    end
    
    def input
      return nil unless input? 

      @input ||= if col = collection 
        select_tag context, [''] + context.eval(col)
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