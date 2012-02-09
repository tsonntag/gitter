module Gitter

  class Header

    attr_reader :grid,:spec, :column
    delegate :name, :to => :spec
    
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
  end

end
