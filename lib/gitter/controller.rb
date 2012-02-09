require 'artdeco'

module Gitter
  module Controller
    
    def self.included(base)
      base.helper_method :render_grid, :decorate
    end

    def render_grid( grid_class, opts = {} )
      grid_class.new self, opts
    end
    
    def decorate( model, *decorator_classes )
      Artdeco::Decorator.new(self).decorate model, *decorator_classes
    end
    
  end
end
