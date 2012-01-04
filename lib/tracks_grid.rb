require 'rails'
require 'active_support/all'
require 'active_record'
require 'action_controller'
require 'will_paginate'
require 'will_paginate/active_record'

#lib_dir = File.expand_path( '../tracks_grid', __FILE__)
#$:.unshift(lib_dir) unless $:.include?(lib_dir)

require 'tracks_grid/version'
require 'tracks_grid/filters'
require 'tracks_grid/columns'
require 'tracks_grid/facet'
require 'tracks_grid/decorator'
require 'tracks_grid/controller'

module TracksGrid

  extend ActiveSupport::Concern
  
  class ConfigurationError < StandardError; end

  included do
    mattr_accessor :filters, :facets, :instance_reader => false, :instance_writer => false

    self.filters = {}
    self.facets= {}
  end

  module ClassMethods

    def scope( &scope )
      if scope
        @scope = scope
      else
        raise ConfigurationError, 'scope undefined' unless @scope
        @scope
      end 
    end

    # Examples:
    #
    # Simple column filter: 
    #
    # class UserGrid
    #   include TracksGrid 
    #
    #   filter :name
    # end
    #
    # Then UserGrid.new( :name => 'Thomas' ) 
    # uses scope.where( :name => 'Thomas' )  
    #
    # You may choose the column as follows:
    #
    # class UserGrid
    #   include TracksGrid 
    #
    #   filter :author, :column => :name
    # end
    #
    # Then UserGrid.new( :author => 'Thomas' )
    # uses scope.where( :name => 'Thomas' )  
    #
    # Multply columns are allowed:
    #
    # class UserGrid
    #   include TracksGrid 
    #
    #   filter :author, :columns => [:name, :surname]
    # end
    #
    # Use :ignore_case => true to ignore case
    #
    # Use :exact => false to search which wildcard (%<term>%)
    # 
    # These options may be overwritten per instance:
    #
    # UserGrid.new :search => 'foo'
    # performs exact search but
    # UserGrid.new :search => 'foo', :exact => true
    # performs exact search 
    #
    # A range filter for a given column:
    #
    # class UserGrid
    #   include TracksGrid 
    #
    #   filter :birthday, :range => true, :column => :born_on
    # end
    #
    # Then UserGrid.new( :birthday_from => '8/2/2011', :birthday_to => '9/1/2011' )
    # or
    # UserGrid.new( :birthday => ('8/2/2011'..'9/1/2011') )
    # 
    # use scope.where( :birthday => ('8/2/2011'..'9/1/2011') )  
    #
    # You can choose different keywords for the params
    #
    # class UserGrid
    #   include TracksGrid 
    #
    #   filter :birthday, :range => true, :from => 'between', :to => 'and', :column => :born_on
    # end
    #
    # UserGrid.new( :between => '8/2/2011', :and => '9/1/2011' )
    # 
    #
    # You can select from other filters:  
    #
    # class UserGrid
    #   include TracksGrid 
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
    # end
    #
    # Then
    # UserGrid.new( :teen => <any> )
    # and
    # UserGrid.new( :generation => :teen )
    # return the same
    #
    # Use the :facet => true option to add the filter to the list of facets
    #
    # class TaskGrid
    #  include TracksGrid
    #
    #  filter :customer, :label => 'Name', :facet => true
    #  filter :priority, :facet => true
    # end
    #
    # Then
    # TaskGrid.new(params).facets 
    # returns a hash 
    #
    # { 'Name' => 
    #      { 'Baker' => 4, 'Miller' => 5 }, 
    #   'priority' => 
    #      { 'low' => 10, 'high' => 12 },
    # }
    #
    # Use :select to group your facets:
    #
    # class UserGrid
    #   ... see above
    #
    #   filter :generation, :label => 'Generation', :select => [ :teen, :twen ], :facet => true
    # end
    #
    # Then UserGrid.new.facets returns
    # { 'Generation' => { 'Teenager' => 25, 'Twen' => 100 } }
    #
    def filter( name, options = {}, &block )
      if options.delete(:range)
        raise ConfigurationError, "no block allowed for range" if block
        return range_filter name, options
      end

      is_facet = options.delete(:facet) # delete option before creating a new filter

      filter = if (select = options.delete(:select))
        raise ConfigurationError, "no block allowed for select" if block
        select_filters = [select].flatten.map{|name| filters[name] or raise ConfigurationError, "no filter for :select => #{name}"}
        SelectFilter.new name, select_filters, options
      elsif block
        BlockFilter.new name, options, &block
      else 
        ColumnFilter.new name, options
      end

      facets[name] = filter if is_facet
      filters[name] = filter
    end

    private

    def range_filter( name, options )
      column = options.delete(:column){name}

      filter options.delete(:from){:"from_#{name}"}, options do |scope, value|
        scope.where "#{column} >= ?", value
      end

      filter options.delete(:to){:"to_#{name}"}, options do |scope, value|
        scope.where "#{column} <= ?", value
      end

      filter name, options do |scope, value|
        scope.where column => value
      end
    end

    def check_opts( opts )
      raise ConfigurationError, "invalid opts #{opts.inspect}" unless opts.empty?
    end
  end

  module InstanceMethods

    # attrs: <filter_name> => <value>, ...
    #        :order => <filter_name>, :desc => true 
    #
    # Example:
    #
    # Select active users, order descending by name
    #
    # class UserGrid
    #   include TracksGrid
    #
    #   filter :active
    # end
    # UserGrid.new :active => true, :order => :name, :desc => true
    #
    # Select users born between 9.2.1980 and 3.10.1990 
    # 
    # class UserGrid
    #   include TracksGrid
    #
    #   filter :birthday, :range => true
    # end
    #
    # UserGrid.new :from_birthday => '1980/9/2', :to_birthday => '1990/10/3'
    #
    def initialize( params = {} )
      params = params.symbolize_keys
      @view_context = params.delete(:view_context)
      @desc = params.delete(:desc)

      # create map name => filter
      @filter_params = {}
      params.each do |name, value|
        if filter = self.class.filters[name] #or raise ArgumentError, "undefined filter #{name}" 
          @filter_params[filter] = value
          params.delete name
        end
      end

      @paginate_hash = { :per_page => params.delete(:per_page){30}, :page => params.delete(:page){1} }

      @params = params
    end

    def scope
      @scope ||= begin
        scope = if @view_context 
          @view_context.instance_eval &self.class.scope
        else
          self.class.scope.call
        end

        @filter_params.each do |filter, value| 
          scope = filter.apply scope, value, @params
        end

        scope
      end
    end

    def method_missing( *args )
      @params[args.first] or super
    end

    def facets
      @facets ||= self.class.facets.values.map do |filter|
        Facet.new filter, scope
      end
    end

    def input_options
      res = {} 
      self.class.filters.each do |name, filter|
        if filter.input?
          res[name] = filter.input_options(@view_context)
        end
      end 
      res
    end

    def inputs
      res = {} 
      self.class.filters.each do |name, filter|
        if i = filter.input(@view_context)
          res[name] = i
        end
      end 
      res
    end

  end

  include Columns
end
