require 'artdeco'

module TracksGrid
  module Controller
    
    # todo
    def render_grid( grid_class, decorator_classes = nil )
      opts = {}
      opts[:decorators] = decorator_classes if decorator_classes
      grid_class.new self, opts
    end
    
    # todo
    def decorate( model, decorator_classes = nil )
      Artdeco::Decorator.new(self).decorator( model, decorator_classes )
    end
    
  end
end