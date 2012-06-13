module Gitter
  
  class AbstractDriver
    include Enumerable
    
    attr_reader :scope
    
    def initialize scope
      @scope = scope
    end

    # methods to be implemented

    # unordered
    
    # order( attr, desc = nil)

    # where( attr_values, opts = {} )
    # where opts may be :exact, :ignore_case, :strip_blank, :find_format

    # where_greater_or_equal( attr, value )

    # where_less_or_equal( attr, value)

    # each(&block)

    # named_scope( name )

    # distict_values( attr )

    def new(scope)
      self.class.new scope
    end

  end
end
