require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_model/callbacks'
require 'artdeco'
require 'i18n'
require 'gitter/filters.rb'
require 'gitter/facet.rb'
  
module Gitter

  module Base
    extend ActiveSupport::Concern

    included do 
      extend ActiveModel::Callbacks
      define_model_callbacks :initialize
      class_attribute :filter_specs, :facets, :instance_reader => false, :instance_writer => false
      self.filter_specs = {}
      self.facets = []
    end
  
    module ClassMethods 
      def scope( &scope )
        if scope
          @scope = scope
        else
          @scope or raise ConfigurationError
        end 
      end

      def order( order = nil )
        order ? (@order = order) : @order
      end

      # Examples:
      #
      # Simple column filter: 
      #
      # class UserGrid << Gitter::Grid
      #
      #   filter :name
      # end
      #
      # Then UserGrid.new( :name => 'Thomas' ) uses scope.where( :name => 'Thomas' )  
      #
      # The column name may be set explicetly:
      #
      #   filter :author, :column => :name
      #
      # Then UserGrid.new( :author => 'Thomas' ) uses scope.where( :name => 'Thomas' )  
      #
      # Multply columns are allowed:
      #
      #   filter :author, :columns => [:name, :surname]
      #
      # Use :ignore_case => true to ignore case
      # Use :exact => false to search which wildcard (%<term>%)
      # 
      # These options may be overwritten per instance:
      #
      # UserGrid.new :author => 'foo'
      # performs exact search but
      #
      # UserGrid.new :author => 'foo', :exact => false
      # uses wildcards
      #
      # search :foo, opts
      # is a shortcut for 
      # filter :foo, { :exact => false, :ignore_case => true }.merge(opts)
      #
      # A range filter for a given column:
      #
      #   filter :birthday, :range => true, :column => :born_on
      #
      # Then UserGrid.new( :birthday_from => '8/2/2011', :birthday_to => '9/1/2011' )
      # or
      # UserGrid.new( :birthday => ('8/2/2011'..'9/1/2011') )
      # 
      # use scope.where( :birthday => ('8/2/2011'..'9/1/2011') )  
      #
      # You can choose different keywords for the params
      #
      #   filter :birthday, :range => true, :from => 'between', :to => 'and', :column => :born_on
      #
      # UserGrid.new( :between => '8/2/2011', :and => '9/1/2011' )
      # 
      #
      # You can select from other filters:  
      #
      #   filter :twen, :label => 'Twen' do |scope|
      #     now = Time.now
      #     scope.where :born_on => (now - 30.years...now - 20.years)
      #   end
      #
      #   filter :teen, :label => 'Teenager' do |scope|
      #     now = Time.now
      #     scope.where :born_on => (now - 19.years...now - 10.years)
      #   end
      #
      #   filter :generation, :select => [ :teen, :twen ]
      #
      # Then
      # UserGrid.new( :teen => <any> )
      # and
      # UserGrid.new( :generation => :teen )
      # return the same
      #
      # Use the :facet => true option to add the filter to the list of facets
      #
      #  filter :customer, :label => 'Name', :facet => true
      #  filter :priority, :facet => true
      #
      # Then TaskGrid.new(params).facets returns a list of facets 
      # where each facet has a name, a label and an array of data objects containing a value and count
      # 
      # e.g.
      # f = TaskGrid.new(params).facets.first
      # f.name           # 'Name'
      # f.data[0].value  # 'Baker'
      # f.data[0].count  # 4 
      # f.data[1].value  # 'Miller'
      # f.data[1].count  # 5 
      #
      # Use :select to group your facets:
      #
      # class UserGrid
      #   ... see above
      #
      #   filter :generation, :label => 'Generation', :select => [ :teen, :twen ], :facet => true
      # end
      #
      # Then f = UserGrid.new.facets.forst
      # f.name           # 'Generation'
      # f.data[0].value  # 'Teenager'
      # f.data[0].count  # 25 
      # f.data[1].value  # 'Twen'
      # f.data[1].count  # 100 
      #
      # Use :scope to filter by a named scope
      #
      # class User < ActiveRecord::Base
      #   scope :children, lambda{ where "birthday > :date", :date => 10.years.ago} 
      # end
      #
      #  filter :scope => :children
      # 
      # Use :select many also refer to named scopes
      #
      # class User < ActiveRecord::Base
      #   scope :teen, lambda{ where :birthday => (10.years.ago..20.years.ago)} 
      #   scope :twen, lambda{ where :birthday => (20.years.ago..29.years.ago)} 
      # end
      #    
      #  filter :generation, :scopes => [:teen, :twen]
      # 
      def filter( *args, &block )
        options = args.extract_options!
        raise ConfigurationError, 'only zero or one argument allowed' if args.size > 1
        name = args.first
  
        filter_spec = case
        when options.delete(:range)
          raise ConfigurationError, "no block allowed for range filter #{name}" if block
          return range_filter name, options # return is required
        when block 
          BlockFilterSpec.new name, options, &block
        when select = options.delete(:select)
          filters = [select].flatten.map{|name| filter_specs[name] || scope_filter(name)}
          SelectFilterSpec.new name, filters, options
        when s = options.delete(:scope)
          scope_filter( s == true ? name : s, options )
        else 
          ColumnFilterSpec.new name, options
        end
  
        self.facets += [name] if options.delete(:facet)
        self.filter_specs = self.filter_specs.merge(name => filter_spec)
        filter_specs
      end
  
      # shortcut for filter name, { :exact => false, :ignore_case => true }.merge(options)
      def search( name, options = {} )
        filter name, { :exact => false, :ignore_case => true }.merge(options)
      end
  
      private
      def range_filter( name, options )
        column = options.delete(:column){name}

        filter options.delete(:from){:"from_#{name}"}, options do |scope, value|
          create_driver(scope).greater_or_equal(column, value).scope
        end

        filter options.delete(:to){:"to_#{name}"}, options do |scope, value|
          create_driver(scope).less_or_equal(column, value).scope
        end

        filter name, :column => column
      end
  
      def scope_filter( name, options = {} )
        BlockFilterSpec.new(name, options){|scope| create_driver(scope).named_scope(name).scope}
      end

    end

    attr_reader :params

    # attrs: <filter_name> => <value>, ...
    #        :order => <filter_name>, :desc => true 
    #
    # Example:
    #
    # Select active users, order descending by name
    #
    # class UserGrid
    #   include Gitter
    #
    #   filter :active
    # end
    # UserGrid.new :active => true, :order => :name, :desc => true
    #
    # Select users born between 9.2.1980 and 3.10.1990 
    # 
    # class UserGrid
    #   include Gitter
    #
    #   filter :birthday, :range => true
    # end
    #
    # UserGrid.new :from_birthday => '1980/9/2', :to_birthday => '1990/10/3'
    #
    # Args may be either the params hash of the request
    # or an object which responds to :params and optionaly to :view_context, e.g. a controller instance
    def initialize( *args )
      run_callbacks :initialize do
        @decorator = Artdeco::Decorator.new *args
        @params = @decorator.params || {}
  
        @selected_filters = {}
        @filters_values = {}
        @params.each do |name, value|
          if spec = self.class.filter_specs[name]
            filter = Filter.new self, spec
            @selected_filters[name] = filter
            @filters_values[filter] = value
          end
        end
      end
    end
    
    def name
      @name ||= self.class.name.underscore
    end
  
    def filters
      @filters = self.class.filter_specs.map{|name,spec| Filter.new(self,spec)}
    end

    def driver
      @driver ||= self.class.create_driver eval(self.class.scope) 
    end

    def filtered_driver
      @filter_driver ||= begin
        d = driver
        @filters_values.each{|filter, value| d = filter.spec.apply(d, value, @params) }
        d
      end
    end
    
    # returns scope which default order
    def scope( ordered = self.class.order )
      @scope ||= (ordered ? filtered_driver.order(self.class.order) : filtered_driver).scope
    end

    def facets
      @facets ||= self.class.facets.map{|name| Facet.new(self, self.class.filter_specs[name]) }
    end
  
    # evaluate data (string or proc) in context of grid
    def eval( data, model = nil )
      @decorator.eval data, model
    end

    def h
      @decorator.h
    end

    def input_tags
      @input_tags ||= begin
        res = {} 
        filters.each do |filter|
          if i = filter.input_tag
            res[filter.name] = i
          end
        end 
        res
      end
    end 

    def translate( prefix, key )
      I18n.translate "gitter.#{name}.#{prefix}.#{key}", :default => key.to_s.humanize
    end
  end
end
