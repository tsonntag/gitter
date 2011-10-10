module TracksGrid

  class AbstractFilter

     attr_reader :name, :label


     def initialize( name, options ={} )
       @name = name
       @label = options.delete(:label){name.to_s.humanize}
       @input_options = options.delete(:input)
       raise ArgumentError, "invalid options #{options.inspect}" unless options.empty?
     end

     def input?
       @input_options
     end

     def input_options( context = nil)
       res = {}
       @input_options.each do |key, value|
         puts "AAAAAAAAAAAAA value=#{value.inspect}"
         res[key] = if value.is_a? Proc
           puts "AAAAAAAAAAAAA proc=true, context=#{context}"
           if context 
              context.instance_exec(&value)
           else
              yield value
           end
         else
           value
         end
       end
       res
     end
  end
end
