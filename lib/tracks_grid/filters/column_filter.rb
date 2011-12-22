module TracksGrid

  class ColumnFilter < AbstractFilter

    attr_reader :column

    def initialize( name, options = {} )
      @column = options.delete(:column){name}
      super
    end

    def apply( scope, *args )
      if args.first.blank?
        scope
      else
        scope.where column => args.first
      end
    end

    def counts( scope )
      scope.group(column).count
    end
   
  end

end 
