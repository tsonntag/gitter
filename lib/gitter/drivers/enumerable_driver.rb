require 'gitter/drivers/abstract_driver'
module Gitter
  
  class EnumerableDriver < AbstractDriver
    
    def count
      scope.size
    end
    
    def order attr, desc = nil
      sign = case desc
        when true, 'true'   then 1 
        when false, 'false' then -1
        else -1 
      end
      new scope.sort{|a,b| sign * (a.send(attr).try(:to_s) <=> b.send(attr).try(:to_s)) }
    end
   
    def unordered
      self
    end

    def group arg
      new scope.group_by(&arg)
    end

    def where attr_values, opts = {}
      exact = opts.fetch(:exact){true}
      ignore_case = opts.fetch(:ignore_case){false}
      strip_blank = opts.fetch(:strip_blank){false}

      attr_texts =  attr_values.map do |attr,value| 
        value = value.strip if strip_blank
        text = exact ? value : /#{value}/
        text = /#{value}/i if ignore_case
        [attr,text]
      end

      s = scope.find_all do |item|
        attr_texts.all? do |attr,text| 
          data = item.send(attr).try(:to_s)
          text === data
        end
      end

      new s
    end

    def greater_or_equal attr, value
      scope.find_all{|item| item.send(:attr) >= value}
    end

    def less_or_equal attr, value
      scope.find_all{|item| item.send(:attr) <= value}
    end

    def each &block
      new scope.each(&block)
    end
    
    def named_scope name
      raise NotImplementError
    end
    
    def distinct_values attr
      group(attr).keys.uniq
    end

    def to_s
      scope.to_s
    end

  end
end
