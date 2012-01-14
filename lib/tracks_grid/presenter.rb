module TracksGrid

  class Presenter
    attr_reader :params, :view_context, :model
    alias_method :h, :view_context

   class << self
     def decorate(model, *args)
       self.new(args).decorate(model)
     end
   end
    #
    # Args may be either the params hash of the request
    # or an object which responds to :params and optionaly to :view_context, e.g. a controller instance
    # If a view_context is given it will be accessible in various blocks by calling :h
    def initialize(*args)
      opts = args.extract_options!
      
      @presenter_classes = ([opts.delete(:presenters)] + [opts.delete(:presenter)]).flatten.compact
      @presenter_classes = nil if @presenter_classes.empty? # required for #decorate

      case args.size
      when 0
        @params = opts.symbolize_keys
        @view_context = @params.delete(:view_context)
      when 1
        arg = args.first
        @view_context = arg.respond_to?(:view_context) ? arg.view_context : nil

        if arg.respond_to? :params
          @params = arg.params.symbolize_keys.merge(opts)
        else
          raise ArgumentError, 'argument must respond_to :params'
        end
      else
        raise ArgumentError, 'too many arguments' if args.size > 1
      end
    end
 
    # evaluate data (string or proc)
    # if model is provided it will accessible in evaluated data
    def eval( data, model = nil )
      @model = decorate model    
      res = case data
      when Proc then @view_context ? instance_exec(&data) : data.call
      else data
      end
      @model = nil
      res
    end

    def method_missing( *args )
      @model ? @model.send(args) : super
    end
    
    def decorate( model, presenter_classes = nil)
      return nil if model.nil?
      presenter_classes ||= @presenter_classes || default_presenter_class(model)
      presenter_classes.each{|pc| model.extend pc}
      model.define_singleton_method(:h){@view_context}
      model
    end
    
    private
    def default_presenter_class(model)
      @_pc_cache ||= {} 
      [@_pc_cache.fetch(model.class){"#{model.class}Presenter".constantize rescue nil}].compact
    end
      
  end
end
