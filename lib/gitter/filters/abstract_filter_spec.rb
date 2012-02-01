module Gitter

  class AbstractFilterSpec

     attr_reader :name, :label, :input_options, :input_tag

     def initialize( name, opts ={} )
       @name = name
       @label = opts[:label]
       @input_options = opts[:input]
       @input_tag = opts[:input_tag]
       @include_blank = opts[:include_blank]
       
       # replace shortcut
       if coll = opts[:input_collection]
         (@input_options||={})[:collection] = coll
       end
     end

     def input?
       @input_options || @input_tag
     end

     def include_blank?
       @include_blank
     end

     def counts( driver )
       { true => apply(driver.unordered).count }
     end

     def distinct_values( driver )
       [ true, false ]       
     end

  end
end
