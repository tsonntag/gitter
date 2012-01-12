module TracksGrid

  module DecoratorMethods

    # extends model with decorator clazz and creates attr_readers for the keys and values given in hash opts
    # Default for clazz  is <self.class>Decorator 
    # If the clazz does not exist the model will not be extended
    # Default for opts are self's opts.
    # In that way self is able to transfer its opts
    def decorate(model, clazz = nil, opts = self.decorator_opts)
      model.extend DecoratorMethods unless model == self
      model.define_singleton_method(:decorator_opts){ opts } 
      clazz ||= model.decorator_class
      model.extend clazz if clazz
      opts.each do |k,value|
        model.define_singleton_method(k){ value } 
      end
      model
    end

    def decorator_class
      if self.class.class_variable_defined? :@@decorator_class
        self.class.class_variable_get :@@decorator_class
      else
        self.class.class_variable_set :@@decorator_class, ("#{self.class}Decorator".constantize rescue nil)
      end
    end

  end

  class Decorator
    class << self
      def decorate( model, *args )
        opts = args.extract_options!
        raise ArgumentError, 'no or one decorator module required' unless args.size <= 1 

        # enable the model to decorate itself
        model.extend DecoratorMethods
        decorator_class = args.first
        model.decorate model, decorator_class, opts
      end
    end
  end

end
