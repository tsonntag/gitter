module TracksGrid

  class AbstractFilterSpec

     attr_reader :name, :label, :input_options, :input_tag

     def initialize( name, opts ={} )
       @name = name
       @label = opts[:label]
       @input_options = opts[:input]
       @input_tag = opts[:input_tag]
       
       # replace shortcut
       if coll = opts[:input_collection]
         (@input_options||={})[:collection] = coll
       end
     end

     def input?
       @input_options || @input_tag
     end

     def counts( driver )
       { true => driver.class.new(apply(driver)).count }
     end

     def distinct_values( driver )
       [ true, false ]       
     end

  end
end
