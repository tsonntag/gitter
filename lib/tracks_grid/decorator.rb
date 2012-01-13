module TracksGrid

  class Decorator
    
    class << self
      def decorate( model, decorator_class = nil )
        decorator_class ||= self.decorator_class
        model.extend decorator_class if decorator_class
      end
      
      private
      def decorator_class(model)
        if model.class.class_variable_defined? :@@decorator_class
          model.class.class_variable_get :@@decorator_class
        else
          model.class.class_variable_set :@@decorator_class, ("#{self.class}Decorator".constantize rescue nil)
        end
      end
      
    end
  end

end
