require 'artdeco'

module Gitter
  module Controller
    
    def render_grid( grid_class, decorator_classes = nil )
      opts = {}
      opts[:decorators] = decorator_classes if decorator_classes
      grid_class.new self, opts
    end
    
    # todo
    def decorate( model, decorator_classes = nil )
      Artdeco::Decorator.new(self).decorate model, decorator_classes
    end
    
  end
end
