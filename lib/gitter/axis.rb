module Gitter

  class Axis

    attr_reader :grid, :name, :attr

    def initialize grid, name, opts = {}
      @grid, @name = grid, name
      @attr = opts.delete(:column){name}
      only = opts.delete(:only){nil}
      case only
      when Hash
        @only_data, @titles= only.keys, only
      else
        @only_data, @titles = only, nil
      end
      @except = opts.delete(:except){[]}
    end


    def data
      data = case attr
      when Symbol,String
        grid.scope.select(attr).uniq.map(&:"#{attr}").sort
      else
        attr
      end

      data = ((data + @only_data) & @only_data).uniq if @only_data
      data = data - @except
    end

    def titles
      if @titles
        data.map{|d|@titles[d]}
      else
        data
      end
    end

    def data_titles
      res = {}	   
      data.each{|d| res[d] = @titles ? @titles[d] : d}
      res
    end

  end
end
