module Gitter

  class Header
    def self.blank
      new :blank, false
    end

    attr_reader :grid, :name, :content, :html_options, :column

    def initialize grid, name, content, opts = {}
      @grid, @name, @content = grid, name, content
      @column = opts.delete(:column){nil}
      @html_options = opts
    end

    def label
      @label ||= case content
	when false then ''
	when nil   then @grid.translate(:headers, name)
        else grid.eval(content)
      end
    end

    def link *args
      if column
        column.link label, *args
      else
	label
      end
    end

    def to_s
      "Header(#{name},html_options=#{html_options},#{column_spec ? ',col':''},label=#{label})"
    end
  end

end
