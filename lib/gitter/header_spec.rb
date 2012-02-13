module Gitter

  class HeaderSpec

    def self.blank
      new :blank, false
    end

    attr_reader :name, :content, :html_options, :column_spec

    def initialize name, content, opts = {}
      @name, @content = name, content
      @column_spec = opts.delete(:column_spec){nil}
      @html_options = opts
    end

    def to_s
      "HeaderSpec(#{name},html_options=#{html_options}#{column_spec ? ',col' : ''})"
    end
  end

end
