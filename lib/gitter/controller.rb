module Gitter
  module Controller

    def self.included base
      base.helper_method :render_grid
    end

    def render_grid  grid_class, opts = {}
      grid_class.new self, opts
    end
  end
end
