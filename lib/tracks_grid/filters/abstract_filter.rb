module TracksGrid

  class AbstractFilter

     attr_reader :name, :label

     def initialize( name, opts ={} )
       @name = name
       @label = opts.fetch(:label){name.to_s.humanize}
       @input_options = opts[:input]

       # replace shortcut
       if coll = opts[:input_collection]
         (@input_options||={})[:collection] = coll
       end
     end

     def input?
       @input_options
     end

     def input( context )
       return nil unless input? 

       if col = collection 
          select_tag context, [''] + context.eval(col)
       else
          text_field_tag grid
       end
     end

     def text_field_tag( context  )
       context.eval proc{ h.text_field_tag name, h.params[name], :class => 'grid'}
     end

     def select_tag( context, collection )
       context.eval proc{ h.select_tag name, context.options_for_select(collection, h.params[name]), :class => 'grid'}
     end
  
     private
     def collection
       @input_options.respond_to?(:[]) && @input_options[:collection]
     end
  end
end
