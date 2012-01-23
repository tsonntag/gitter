require 'tracks_grid/drivers/abstract_driver'
module TracksGrid
  
  class ActiveRecordDriver < AbstractDriver
    
    delegate :group, :count, :to => :scope
    
    def order( attr, desc = nil)
      what = case desc
        when true then "#{attr} DESC"
        when String then desc
        else attr
      end
      new scope.order(what)
    end
   
    def where( attr_values, exact = true, ignore_case = true)
      # has range?
      return new scope.where(attr_values) if Range === attr_values.values.first

      tokens = {}

      conditions = attr_values.map do |attr,value| 
        raise ArgumentError, "invalid range #{value} for #{attr}" if Range === value
        text = exact ? value : "%#{value}%"
        col, token = attr, ":#{attr}" 
        col, token = upper(col), upper(token) if ignore_case
        tokens[attr] = text 
        "#{col} #{exact ? '=' : 'LIKE'} #{token}"
      end

      new scope.where("( #{conditions * ') OR ('} )", tokens)
    end

    def greater_or_equal( attr, value )
      new scope.where("#{attr} >= ?", value)
    end

    def less_or_equal( attr, value)
      new scope.where("#{attr} <= ?", value)
    end

    def each( &block )
      new scope.each(&block)
    end
    
    def named_scope( name )
      new scope.send(name)
    end
    
    def distinct_values( attr )
      scope.select("DISTINCT #{attr}").map(&attr)
    end

    private 

    def upper(text)
      "upper(#{text})"
    end
  end
end
