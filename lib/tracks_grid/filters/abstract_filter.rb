module TracksGrid

  class AbstractFilter

     attr_reader :name, :label

     def initialize( name, opts ={} )
       @name = name
       @label = opts.fetch(:label){name.to_s.humanize}
       @input_options = opts[:input]
     end

     def input?
       @input_options
     end

     def input_options( context = nil )
       res = {}
       @input_options.each do |key, value|
         res[key] = if value.is_a? Proc
           if context 
              context.instance_exec(&value)
           else
              yield value
           end
         else
           value
         end
       end if @input_options.respond_to? :each
       res
     end

     def input( context = nil )
       return nil unless input? 

       if col = input_options(context)[:collection]
          select_tag context, col
       else
          text_field_tag context
       end
     end

     def text_field_tag( context )
       context.text_field_tag name, context.params[name], :class => 'grid'
     end

     def select_tag( context, collection )
       context.select_tag name, context.options_for_select(collection, context.params[name]), :class => 'grid'
     end
  end
end
