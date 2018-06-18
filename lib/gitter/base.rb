require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'
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

    attr_reader :params, :options, :values

    def initialize *args
      opts = args.extract_options!
      @params = opts.delete(:params){opts}
      @filters, @values, @facets = {}.with_indifferent_access, {}.with_indifferent_access, {}.with_indifferent_access
      scope = opts.delete(:scope){nil}
      @options = opts.dup

      instance_eval &self.class.grid

      @scope = scope || @scope

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

    def filter_for name
      @filters[name]
    end

    def label name
      filter_for(name).label
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
        @values.each do |name, value|
          d = @filters[name].apply d, value
        end
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
        if opts[:facet] && opts[:facet] != true
          opts.merge! values: opts[:facet]
        end
        select = [select] unless select.respond_to?(:each)
        filters = select.map do |label,filter_name|
          filter_name ||= label
          @filters[filter_name] || scope_filter(label,filter_name,label: label)
        end
        SelectFilter.new self, name, filters, opts
      when scope_name = opts.delete(:scope)
        scope_name = name if scope_name == true
        scope_filter name, scope_name
      else
        if opts[:facet] && opts[:facet] != true
          opts.merge! values: opts[:facet]
        end
        ColumnFilter.new self, name, opts
      end

      @facets[name] = Facet.new(filter) if opts[:facet]
      @filters[name] = filter
    end

    # shortcut for filter name, { exact: false, ignore_case: true, strip_blank: true }.merge(options)
    def search name, opts = {}
      filter name, { exact: false, ignore_case: true, strip_blank: true }.merge(opts)
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

      filter name, column: column
    end

    def scope_filter name, scope_name, opts = {}
      BlockFilter.new(self, name, opts){|scope| create_driver(scope).named_scope(scope_name).scope}
    end

  end
end
