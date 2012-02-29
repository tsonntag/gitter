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
  
    attr_reader :params, :facets

    def initialize *args
      opts = args.extract_options!
      @decorator = Artdeco::Decorator.new *args, opts
      @params = @decorator.params.fetch(key){{}}.symbolize_keys

      @filters = {}
      @facets = [] 
      instance_eval &self.class.grid

      @scope = opts.delete(:scope){@scope}

      @filters_values = {}
      params.each do |name, value|
        if filter = @filters[name]
          @filters_values[filter] = value
        end
      end
    end
    
    def selected_value filter
      @filters_values[filter] 
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
        @filters_values.each{|filter, value| d = filter.apply d, value, params }
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
      options = args.extract_options!
      raise ConfigurationError, 'only zero or one argument allowed' if args.size > 1
      name = args.first

      filter = case
      when options.delete(:range)
        raise ConfigurationError, "no block allowed for range filter #{name}" if block
        return range_filter name, options # return is required
      when block 
        BlockFilter.new self, name, options, &block
      when select = options.delete(:select)
        filters = [select].flatten.map{|name| @filters[name] || scope_filter(name)}
        SelectFilter.new self, name, filters, options
      when s = options.delete(:scope)
        scope_filter( s == true ? name : s, options )
      else 
        ColumnFilter.new self, name, options
      end

      @facets << Facet.new(filter) if options.delete(:facet)
      @filters[name] = filter 
    end

    # shortcut for filter name, { :exact => false, :ignore_case => true }.merge(options)
    def search name, options = {} 
      filter name, { :exact => false, :ignore_case => true }.merge(options)
    end

    private

    def range_filter name, options
      column = options.delete(:column){name}

      filter options.delete(:from){:"from_#{name}"}, options do |scope, value|
        create_driver(scope).greater_or_equal(column, value).scope
      end

      filter options.delete(:to){:"to_#{name}"}, options do |scope, value|
        create_driver(scope).less_or_equal(column, value).scope
      end

      filter name, :column => column
    end

    def scope_filter name, options = {}
      BlockFilter.new(self,name, options){|scope| create_driver(scope).named_scope(name).scope}
    end

  end
end
