module TracksGrid

  class DecoratorError < StandardError; end

  module DecoratorMethods
    def decorate(model, clazz = nil, opts = self.decorator_opts)
      clazz ||= decorator_class(model)
      model.extend clazz if clazz

      opts.each do |k,value|
        model.class.send :attr_reader, k 
        model.send :instance_variable_set, "@#{k}", value
      end

      model
    end

    private
    def decorator_class(model)
      c = model.class
      begin 
        d = "#{c}Decorator"
        d.constantize 
      rescue
        if c = c.superclass
          retry 
        else
          return nil
        end
      end
    end
  end

  class Decorator
    class << self
      def decorate( model, *args )
        opts = args.extract_options!
        raise ArgumentError, 'no or one decorator module required' unless args.size <= 1 
        decorator_class = args.first

        model.class.send :attr_accessor, :decorator_opts
        model.decorator_opts = opts
        model.extend DecoratorMethods
        model.decorate model, decorator_class
      end
    end
  end

end
