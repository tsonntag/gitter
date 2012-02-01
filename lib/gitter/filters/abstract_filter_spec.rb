module Gitter

  class AbstractFilterSpec

    attr_reader :name, :label, :input_options, :input_tag, :format

    def initialize( name, opts ={} )
       @name = name
       @label = opts[:label]
       @input_options = opts[:input]
       @input_tag = opts[:input_tag]
       @include_blank = opts[:include_blank]
       
       @exact = opts.fetch(:exact){true}
       @ignore_case = opts.fetch(:ignore_case){false}
       @format = opts[:format]

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

    def exact(opts = {})
      opts.fetch(:exact){@exact}
    end

    def ignore_case(opts = {})
      opts.fetch(:ignore_case){@ignore_case}
    end

  end
end
