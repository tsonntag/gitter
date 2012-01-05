module TracksGrid

  module DecoratorMethods
    def decorate(model, clazz = nil, opts = self.decorator_opts)
      clazz ||= "#{model.class.name}Decorator".constantize
      model.extend clazz

      opts.each do |k,value|
        model.class.send :attr_reader, k 
        model.send :instance_variable_set, "@#{k}", value
      end

    end
  end

  class Decorator
    class << self
      def decorate( model, *args )
        opts = args.extract_options!
        raise ArgumentError, 'no or one decorator module required' unless args.size <= 1 

        model.class.send :attr_accessor, :decorator_opts
        model.decorator_opts = opts
        model.extend DecoratorMethods
        model.decorate model, args.first
      end
    end
  end

end
