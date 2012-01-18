module TracksGrid
  
  class AbstractDriver
    include Enumerable
    
    attr_reader :scope
    
    def initialize(scope)
      @scope = scope
    end

    # methods to be implemented
    
    # order( attr, desc = nil)

    # where( attr_values, exact = true, ignore_case = true)

    # where_greater_or_equal( attr, value )

    # where_less_or_equal( attr, value)

    # each(&block)

    # named_scope( name )

    # named_scope?( name )

    # distict_values( attr )

    def new(scope)
      self.class.new scope
    end

  end
end
