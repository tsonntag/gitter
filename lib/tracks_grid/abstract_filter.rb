module TracksGrid

  class AbstractFilter

     attr_reader :name, :label

     def initialize( name, options ={} )
       puts "name=#{name}, options=#{options.inspect}"

       @name, @options = name, options
       @label = options[:label] || name
     end

  end
end
