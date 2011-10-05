module TracksGrid

  class AbstractFilter

     attr_reader :name, :label

     def initialize( name, options ={} )
       @name, @options = name, options
       @label = options.delete(:label){name.to_s.humanize}
     end

  end
end
