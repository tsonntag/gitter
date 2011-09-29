module TracksGrid

  class ColumnFilter < AbstractFilter

    attr_reader :column

    def initialize( name, options)
      @column = options[:column] || name
      super
    end

    def apply( scope, value )
      scope.where column => value
    end

    def counts( scope )
      scope.group(column).count
    end
   
  end

end 
