require 'rails'
require 'active_support/all'
require 'active_record'
require 'action_controller'
require 'will_paginate'
require 'will_paginate/active_record'
require 'draper/all_helpers'

lib_dir = File.expand_path( '../tracks_grid', __FILE__)
$:.unshift(lib_dir) unless $:.include?(lib_dir)

require 'version'
require 'filters'
require 'column'
require 'facet'

module TracksGrid
  extend ActiveSupport::Concern
  
  class ConfigurationError < StandardError; end

  included do
    mattr_accessor :filters, :facets, :columns, :instance_reader => false, :instance_writer => false

    self.filters = {} 
    self.facets = {} 
    self.columns = {}

    ActionController::Base.send :extend, Draper::AllHelpers
  end

  module ClassMethods

    def scope( &scope )
      if scope
        @scope = scope
      else
        raise ConfigurationError, 'scope undefined' unless @scope
        @scope.call         
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
    # A range filter for a given column:
    #
    # class OrderGrid
    #   include TracksGrid 
    #
    #   filter :order_date, :range => true, :column => ordered_at
    # end
    #
    # Then OrderGrid.new( :order_date_from => '8/2/2011', :order_date_to => '9/1/2011' )
    # or
    # OrderGrid.new( :order_date => ('8/2/2011'..'9/1/2011') )
    # 
    # use scope.where( :ordered_at => ('8/2/2011'..'9/1/2011') )  
    #
    # You can choose different keywords the params
    #
    # class OrderGrid
    #   include TracksGrid 
    #
    #   filter :order_date, :range => true, :from => 'between', :to => 'and', :column => ordered_at
    # end
    #
    # OrderGrid.new( :between => '8/2/2011', :and => '9/1/2011' )
    # 
    #
    # You can select from other filters:  
    #
    # class OrderGrid
    #   include TracksGrid 
    #
    #   filter :last_week, :label => 'Last week' do |scope|
    #     now = Time.now
    #     scope.where :order_date => (now - 7.days...now)
    #   end
    #
    #   filter :last_year, :label => 'Last year' do |scope|
    #     now = Time.now
    #     scope.where :order_date => (now - 1.year...now)
    #   end
    #
    #   filter :order_date, :select => [ :last_week, :last_week ]
    #
    # end
    #
    # Then
    # OrderGrid.new( :last_week => <any> )
    # and
    # OrderGrid.new( :order_date => :last_week )
    # return the same
    #
    # Use the :facet => true option to add the filter to the list of facets
    #
    # class OrderGrid
    #  include TracksGrid
    #
    #  filter :customer, :label => 'Name', :facet => true
    #  filter :priority, :facet => true
    # end
    #
    # Then
    # Order.new(params).facets 
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
    # class OrderGrid
    #   ... see above
    #
    #   filter :order_date, :label => 'Date', :select => [ :last_week, :last_week ], :facet => true
    # end
    #
    # Then OrderGrid.new.facets returns
    # { 'Date' => { 'Last week' => 25, 'Last year' => 100 } }
    #
    def filter( name, options = {}, &block )
      if options.delete(:range)
        raise ConfigurationError, "no block allowed for range" if block
        return range_filter name, options
      end

      filter = new_filter name, options, block

      facets[name] = filter if options.delete(:facet)
      filters[name] = filter
    end

    # class SearchGrid
    #   include TracksGrid
    #   search :search_text, :term, :columns => [ :order_no, :customer ]
    # end
    #
    # creates identical filter :search_text and :term which search a given value in columns
    # :order_no, :customer
    # 
    # g = SearchGrid.new :search_text => 'foo'
    # searches %foo% in :order_no and :customer  
    #
    # Options:
    #   :exact
    #     if true makes exact match
    #     if false uses LIKE '%<value>%'  (default)
    #               
    #  :ignore_case 
    #     if true ignores case (default)
    #
    # These options may by overwritten for each instance.
    # Example:
    #
    # class SearchGrid
    #   include TracksGrid
    #   search :search, :column => :order_no, :exact => false
    # end
    #
    # SearchGrid.new :search => 'foo'
    # performs non exact search but
    # SearchGrid.new :search => 'foo', :exact => true
    # performs exact search 
    #
    def search( *args )
      opts = args.extract_options!
      exact = opts.delete(:exact){false}
      cols = opts.delete(:columns) or raise ConfigurationError, 'search requires :columns'
      cols = [cols].flatten
      ignore_case = opts.delete(:ignore_case){true}
      check_opts opts
      args.each do |name|
        filter name do |scope, *args|
          # instance options may overwrite class options
          opts = args.extract_options!
          exact = opts.delete(:exact){exact}
          ignore_case = opts.delete(:ignore_case){ignore_case}

          raise ArgumentError, "too many arguments #{args.inspect}" if args.size != 1
          value = args.first

          conditions = cols.map do |col| 
            if ignore_case
              col = "upper(#{col})"
              token = "upper(:text)"
            else
              token = ':text'
            end
            "#{col} #{exact ? '=' : 'LIKE'} #{token}"
          end
          text = exact ? value : "%#{value}%"
          scope.where "( #{conditions * ') OR ('} )", :text => text 
        end
      end
    end

    # adds a column to be display
    # Example:
    #
    # column(:order_date)
    # displays :order_date of the model 
    # 
    # A header may be specified by :header:
    #
    # column(:order_date, :header => 'Order Date'
    #
    # Supply a block to computed the column's data
    #
    # column(:year, :header => 'Year') do |model|
    #   model.order_date.strftime("%Y") 
    # end
    # 
    def column( name, opts = {}, &block )
      columns[name] = Column.new name, opts, block
    end

    def helpers
      @helpers ||= ApplicationController::all_helpers
    end
    alias_method :h, :helpers

    private

    def new_filter( name, options, block )
      if select = options.delete(:select)
        raise ConfigurationError, "no block allowed for select" if block
        select_filters = [select].flatten.map{|name| filters[name] or raise ConfigurationError, "no filter for :select => #{name}"}
        SelectFilter.new name, select_filters, options
      elsif block
        BlockFilter.new name, options, &block
      else 
        ColumnFilter.new name, options
      end
    end

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
    # Select orders for order_date  9.2.2011 until 3.10.2011 
    # 
    # class OrderGrid
    #   include TracksGrid
    #
    #   filter :order_date, :range => true
    # end
    #
    # OrderGrid.new :from_order_date => '2011/9/2', :to_order_date => '2011/10/3'
    #
    def initialize( params = {} )
      @desc = params.delete(:desc)
      if order = params.delete(:order)
        @order_col = self.class.columns[order] or raise ArgumentError, "unknown order column #{order}"
      else
        @order_col = nil
        raise ArgumentError, ':desc given but no :order' if @desc 
      end

      # find filters by name
      @filter_params = {}
      params.each do |name, value|
        if filter = self.class.filters[name] #or raise ArgumentError, "undefined filter #{name}" 
          @filter_params[filter] = value
          params.delete name
        end
      end
      @params = params
    end

    def scope
      scope = self.class.scope  

      @filter_params.each do |filter, value| 
        scope = filter.apply scope, value, @params
      end

      if @order_col
        @order_col.ordered scope, @desc
      else
        scope
      end

    end

    #def method_missing( *args )
    #  scope.send *args
    #end

    def facets
      self.class.facets.values.map do |filter|
        Facet.new filter, scope
      end
    end

    def paginate
      scope.paginate :page => (@params[:page]||1), :per_page => (@params[:per_page]||30)
    end

    def headers
      columns.map(&:header)
    end

    def row_for(model)
      #puts "row_for(#{model.inspect})"
      columns.map do |column|
        column.apply model
      end
    end

    def rows( scope = self.scope )
      scope.map do |model|
        row_for model
      end
    end

    def columns
      @columns ||= self.class.columns.values
    end

    def helpers
      self.class.helpers
    end
  end

end
