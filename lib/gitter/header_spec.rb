module Gitter

  class HeaderSpec

    def self.blank
      new :blank, false
    end

    attr_reader :name, :content, :colspan, :rowspan, :column_spec

    def initialize name, content, opts = {}
      @name, @content = name, content
      @colspan = opts[:colspan] || 1
      @rowspan = opts[:rowspan] || 1
      @column_spec = opts[:column_spec]
    end

    def to_s
      "HeaderSpec(#{name},colspan=#{colspan},rowspan=#{rowspan}#{column_spec ? ',col' : ''})"
    end
  end

end
