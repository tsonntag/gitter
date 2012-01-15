module TracksGrid
  
  class ActiveRecordDriver
    
    delegate :group, :count, :to => :scope
    
    def initialize(scope)
      @scope = scope
    end
    
    def order( attr, desc = nil)
      desc ||= "#{attr} DESC"
      new scope.order(desc ? desc : attr)
    end
   
    def where( attr_values, exact => true, ignore_case = true)
      tokens = {}
      conditions = attr_values.map do |attr,value| 
        text = exact ? value : "%#{value}%"
         
        if ignore_case
          col = "upper(#{attr})"
          token = "upper(:text)"
        else
          col = attr
          tokens[:"#{attr}"] = text 
        end
        "#{col} #{exact ? '=' : 'LIKE'} #{token}"
      end

      new scope.where("( #{conditions * ') OR ('} )", tokens)
    end

    def where_greater_or_equal( attr, value )
      new scope.where("#{column} >= ?", value)
    end

    def where_less_or_equal( attr, value)
      new scope.where("#{column} <= ?", value)
    end

    def each(&block)
      new scope.each(block)
    end
    
    def method_missing(*args)
      new scope.send(*args)
    end
    
    private
    def new( scope )
      self.class.new scope
    end
  end
end
