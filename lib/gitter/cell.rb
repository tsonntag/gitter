module Gitter

  class Cell

    attr_reader :content, :html_opts

    def initialize content, html_opts = {}
      @content, @html_opts = content, html_opts
    end
  end
end
