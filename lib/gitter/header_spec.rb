module Gitter

  class HeaderSpec

    def self.blank
      new :blank, false
    end

    attr_reader :name, :content, :span, :column_spec

    def initialize name, content, opts = {}
      @name, @content = name, content
      @span = opts[:span] || 1
      @column_spec = opts[:column_spec]
    end

    def to_s
      "HeaderSpec(#{name})#{span > 1 ? ",#{span}": ""}#{column_spec ? ',col' : ''})"
    end
  end

end
