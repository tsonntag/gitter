module Gitter

  class Header

    attr_reader :grid, :spec, :column
    delegate :name, :span, :column_spec, :to => :spec
    
    def initialize grid, spec, opts = {}
      @grid, @spec = grid, spec
      @column = opts[:column]
    end

    def label
      @label ||= case spec.content
	when false then ''
	when nil   then grid.translate(:headers, name)
        else grid.eval(spec.content)
      end
    end

    def link *args
      column.link label, *args
    end

    def to_s
      "Header(#{name},#{span > 1 ? span+',' : ''}#{column_spec ? 'col,':''}label=#{label})"
    end
  end

end
