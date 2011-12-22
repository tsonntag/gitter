module TracksGrid

  class ColumnFilter < AbstractFilter

    attr_reader :column, :exact, :ignore_case

    def initialize( name, opts = {} )
      @column = opts.delete(:column){name}
      @exact = opts.delete(:exact){false}
      @ignore_case = opts.delete(:ignore_case){true}
      super
    end

    def apply( scope, *args )
      value = args.first
      if value.blank?
        scope
      else
        text = exact ? value : "%#{value}%"
        scope.where "( #{condition} )", :text => text
      end
    end

    def counts( scope )
      scope.group(column).count
    end
   
    private
    def condition
      @conditions ||= begin
        if ignore_case
          col = "upper(#{column})"
          token = "upper(:text)"
        else
          col = column
          token = ':text'
        end
        "#{col} #{exact ? '=' : 'LIKE'} #{token}"
      end
    end

  end

end 
