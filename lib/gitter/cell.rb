module Gitter

  class Cell

    attr_reader :content, :html_options

    def initialize content, html_options = {}
      @content, @html_options = content, html_options
    end
  end
end
