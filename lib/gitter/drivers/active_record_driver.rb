require 'gitter/drivers/abstract_driver'
module Gitter
  
  class ActiveRecordDriver < AbstractDriver
    
    delegate :group, :count, :to => :scope
    
    def order( attr, desc = nil)
      what = case desc
        when true, 'true' then "#{attr} DESC"
        when false, 'false' then attr
        when String then desc
        else attr 
      end
      new scope.except(:order).order(what)
    end
   
    def unordered
      new scope.except(:order)
    end

    def where( attr_values, exact = true, ignore_case = true, format = nil)
      # has range?
      return new scope.where(attr_values) if Range === attr_values.values.first

      tokens = {}
      token_i = 0

      conditions = attr_values.map do |attr,value| 
        raise ArgumentError, "invalid range #{value} for #{attr}" if Range === value
        text = exact ? value : "%#{value}%"
        col, token = attr, ":q#{token_i}"
        col, token = upper(col), upper(token) if ignore_case
        puts "AAAAAAAAAAAA before #{col}, #{token}"
        col = format.call(col) if format
        puts "AAAAAAAAAAAA after #{col}, #{token}"
        tokens[:"q#{token_i}"] = text 
        token_i += 1
        "#{col} #{exact ? '=' : 'LIKE'} #{token}"
      end

      puts "CCCCCCCCCCCC #{conditions.inspect},  tokens=#{tokens.inspect}"
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
