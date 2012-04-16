require 'active_support/concern'
require 'artdeco'
require 'gitter/filters.rb'
require 'gitter/facet.rb'
  
module Gitter

  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def grid &grid
        if grid
          @grid = grid
        else
          @grid or raise ArgumentError, 'undefined grid'
        end
      end
    end
  
    attr_reader :params, :decorator, :options

    def initialize *args
      opts = args.extract_options!
      @decorator = Artdeco::Decorator.new *args, opts
      @params = @decorator.params.fetch(key){{}}.symbolize_keys

      @filters, @values, @facets = {}, {}, {} 
      scope = opts.delete(:scope){nil}
      @options = opts.dup

      instance_eval &self.class.grid

      @scope = scope || @scope

      @decorator.params.symbolize_keys.each do |name, value|
        if (name != key) and (filter = @filters[name]) and not filter.param_scoped?
          @values[name] = value
        end
      end
      @params.each do |name, value|
        if filter = @filters[name]
          @values[name] = value
        end
      end
    end
    
    def filter_value filter_name
      @values[filter_name] 
    end

    def filters
      @filters.values 
    end

    def driver
      @driver ||= begin
        scope = Proc === @scope ? instance_eval(&@scope) : @scope
        create_driver scope
      end
    end

    def filtered_driver
      @filter_driver ||= begin
        d = driver
        @values.each{|name, value| d = @filters[name].apply d, value, params }
        d
      end
    end
    
    def scope &scope
      if scope
        @scope = scope
       else
        filtered_driver.scope
      end 
    end

    def filter *args, &block
      opts = args.extract_options!
      raise ConfigurationError, 'only zero or one argument allowed' if args.size > 1
      name = args.first

      filter = case
      when opts.delete(:range)
        raise ConfigurationError, "no block allowed for range filter #{name}" if block
        return range_filter name, opts # return is required
      when block 
        BlockFilter.new self, name, opts, &block
      when select = opts.delete(:select)
        filters = [select].flatten.map{|name| @filters[name] || scope_filter(name)}
        SelectFilter.new self, name, filters, opts
      when s = opts.delete(:scope)
        scope_filter( s == true ? name : s, opts )
      else 
        ColumnFilter.new self, name, opts
      end

      @facets[name] = Facet.new(filter) if opts.delete(:facet)
      @filters[name] = filter 
    end

    # shortcut for filter name, { :exact => false, :ignore_case => true }.merge(options)
    def search name, opts = {} 
      filter name, { :exact => false, :ignore_case => true }.merge(opts)
    end

    def facets
      @_facets_ ||= @facets.values
    end

    def facet name
      @facets[name]
    end

    private

    def range_filter name, opts
      column = opts.delete(:column){name}

      filter opts.delete(:from){:"from_#{name}"}, opts do |scope, value|
        create_driver(scope).greater_or_equal(column, value).scope
      end

      filter opts.delete(:to){:"to_#{name}"}, opts do |scope, value|
        create_driver(scope).less_or_equal(column, value).scope
      end

      filter name, :column => column
    end

    def scope_filter name, opts = {}
      BlockFilter.new(self,name, opts){|scope| create_driver(scope).named_scope(name).scope}
    end

  end
end
