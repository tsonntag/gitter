module TracksGrid

  class DecoratorError < StandardError; end

  module DecoratorMethods
    extend ActiveSupport::Memoizable
    include Benchmark

    def decorate(model, clazz = nil, opts = self.decorator_opts)
      unless model == self
        model.extend DecoratorMethods
      end
      model.define_singleton_method(:decorator_opts){ opts } 

      clazz ||= model.decorator_class

      model.extend clazz if clazz

      opts.each do |k,value|
        model.define_singleton_method(k){ value } 
      end

      model
    end

    def decorator_class
      "#{self.class}Decorator".constantize rescue nil
    end
    memoize :decorator_class

  end

  class Decorator
    class << self
      def decorate( model, *args )
        opts = args.extract_options!
        raise ArgumentError, 'no or one decorator module required' unless args.size <= 1 
        decorator_class = args.first

        model.extend DecoratorMethods
        model.decorate model, decorator_class, opts
      end
    end
  end

end
