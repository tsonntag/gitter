module Gitter

  class HeaderSpec

    attr_readet :name, :content, :span, :column_spec

    def initialize name, content, opts = {}
      @name, @content = content, name
      @span = opts[:span] || 1
      @column_spec = opts[:column_spec]
    end

  end

end
