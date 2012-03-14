module Gitter

  class Header
    def self.blank
      new :blank, false
    end

    attr_reader :grid, :content, :html_options, :column

    def initialize grid, *args
      opts = args.extract_options!
      raise ArgumentError, 'too many arguments' if args.size > 1
      @grid = grid
      @content = args.first
      @column = opts.delete(:column){nil}
      @html_options = opts
    end

    def label
      @label ||= case content
	when false then ''
	when Symbol then grid.translate(:headers, name)
        else content
      end
    end

    def link *args
      if column
        column.link label, *args
      else
	label
      end
    end

    def name
      @name ||= Symbol === content ? content : 'n/a'
    end

    def to_s
      "Header(#{name},html_options=#{html_options},#{column ? ',col':''},label=#{label})"
    end
  end

end
