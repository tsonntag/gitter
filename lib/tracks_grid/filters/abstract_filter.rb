module TracksGrid

  class AbstractFilter

     attr_reader :name, :label

     def initialize( name, options ={} )
       @name = name
       @label = options.delete(:label){name.to_s.humanize}
       raise ArgumentError, "invalid options #{options.inspect}" unless options.empty?
     end

  end
end
