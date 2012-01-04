module TracksGrid

  class Decorator
    attr_reader :model, :view_context

    class << self
      def create( model, view_context )
        decorator_class(model).new model, view_context 
      end

      def render( model, view_context, block )
        create( model, view_context ).instance_eval &block
      end

      private
      def decorator_class( model )
        clazz = model.class.name + 'Decorator'
        clazz.constantize rescue self
      end

    end

    attr_reader :view_context, :model

    def initialize( model, view_context )
      @model, @view_context = model, view_context
    end

    def method_missing( *args )
      @model.send *args
    end

    alias_method :helpers, :view_context 
    alias_method :h, :view_context 
  end

end
