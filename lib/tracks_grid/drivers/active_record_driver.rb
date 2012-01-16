require 'tracks_grid/drivers/abstract_driver'
module TracksGrid
  
  class ActiveRecordDriver < AbstractDriver
    
    delegate :group, :count, :to => :scope
    
    def order( attr, desc = nil)
      desc ||= "#{attr} DESC"
      new scope.order(desc ? desc : attr)
    end
   
    def where( attr_values, exact = true, ignore_case = true)
      tokens = {}
      conditions = attr_values.map do |attr,value| 
        text = exact ? value : "%#{value}%"
         
        col = attr
        token = ":#{attr}" 

        if ignore_case
          col = upper col
          token = upper token
        end

        tokens[attr] = text 

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
      new scope.each(&block)
    end
    
    def named_scope( name )
      new scope.send(name)
    end
    
    private 

    def upper(text)
      "upper(#{text})"
    end
  end
end
