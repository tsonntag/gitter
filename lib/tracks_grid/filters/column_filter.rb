module TracksGrid

  class ColumnFilter < AbstractFilter

    attr_reader :columns, :exact, :ignore_case

    def initialize( name, opts = {} )
      @columns = [opts[:column]||opts[:columns]|| name].flatten
      @exact = opts.fetch(:exact){true}
      @ignore_case = opts.fetch(:ignore_case){false}
      super
    end

    def apply( scope, *args )
      opts = args.extract_options!

      raise ArgumentError, "too many arguments #{args.inspect}" unless args.size == 1
      value = args.first

      return scope if value.blank?

      exact = opts.fetch(:exact){@exact}
      ignore_case = opts.fetch(:ignore_case){@ignore_case}
      text = exact ? value : "%#{value}%"
      conditions = columns.map do |column| 
        if ignore_case
          col = "upper(#{column})"
          token = "upper(:text)"
        else
          col = column
          token = ':text'
        end
        "#{col} #{exact ? '=' : 'LIKE'} #{token}"
      end

      scope.where "( #{conditions * ') OR ('} )", :text => text
    end

    def counts( scope )
      scope.group(column).count
    end
   
  end

end 
