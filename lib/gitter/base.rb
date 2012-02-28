require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_model/callbacks'
require 'artdeco'
require 'gitter/filters.rb'
require 'gitter/facet.rb'
  
module Gitter

  module Base
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :initialize
      self.class_attribute :grid, :instance_reader => false, :instance_writer => false
    end

    module ClassMethods
      def grid &grid
        @grid = grid
      end
    end
  
    attr_reader :params, :facets

    def initialize *args
      run_callbacks :initialize do
        opts = args.extract_options!
        @decorator = Artdeco::Decorator.new *args, opts
        @params = @decorator.params.fetch(key){{}}.symbolize_keys

	@filters = {}
	@facets = [] 
	self.class.grid.call

        @scope = opts.delete(:scope){@scope}

        @selected_filters, @filters_values = {}, {}
        @params.each do |name, value|
          if filter = @filters[name]
            @selected_filters[name] = filter
            @filters_values[filter] = value
          end
        end
      end
    end
    
    def filters
      @filters.values 
    end

    def driver
      @driver ||= create_driver eval(@scope) 
    end

    def filtered_driver
      @filter_driver ||= begin
        d = driver
        @filters_values.each{|filter, value| d = filter.apply d, value, @params }
        d
      end
    end
    
    # evaluate data (string or proc) in context of grid
    def eval data, model = nil 
      @decorator.eval data, model
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
        BlockFilterSpec.new self, name, options, &block
      when select = options.delete(:select)
        filters = [select].flatten.map{|name| filter_specs[name] || scope_filter(name)}
        SelectFilterSpec.new self, name, filters, options
      when s = options.delete(:scope)
        scope_filter( s == true ? name : s, options )
      else 
        ColumnFilterSpec.new self, name, options
      end

      @facets << Facet.new(self, filter) if options.delete(:facet)
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
      BlockFilterSpec.new(self,name, options){|scope| create_driver(scope).named_scope(name).scope}
    end

  end
end
