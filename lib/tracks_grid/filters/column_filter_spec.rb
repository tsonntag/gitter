module TracksGrid

  class ColumnFilterSpec < AbstractFilterSpec

    attr_reader :columns, :exact, :ignore_case

    def initialize( name, opts = {} )
      @columns = [opts[:column]||opts[:columns]||name].flatten
      @exact = opts.fetch(:exact){true}
      @ignore_case = opts.fetch(:ignore_case){false}
      super
    end

    def apply( driver, *args )
      opts = args.extract_options!

      raise ArgumentError, "too many arguments #{args.inspect}" unless args.size == 1
      value = args.first

      return driver if value.blank?

      exact = opts.fetch(:exact){@exact}
      ignore_case = opts.fetch(:ignore_case){@ignore_case}
      attr_values = columns.inject({}){|memo,column| memo[column.name] = value}
      driver.where attr_values, exact, ignore_case
    end

    def counts( driver )
      if columns.size == 1
        driver.group(columns.first).count
      else
        driver.count
      end
    end
   
  end

end 
