require 'active_support/all'
require 'active_record'

dir = File.expand_path '../tracks_grid', __FILE__
$:.unshift(dir) unless $:.include? dir
require 'abstract_filter.rb'
require 'block_filter.rb'
require 'column_filter.rb'
require 'select_filter.rb'
require 'facet.rb'

module TracksGrid
  extend ActiveSupport::Concern
  
  class ConfigurationError < StandardError; end

  included do
    mattr_accessor :filters, :facets, :instance_reader => false, :instance_writer => false

    self.filters = {} 
    self.facets = {} 
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
         raise ArgumentError, "no block allowed for range" if block
         return range_filter name, options
      end

      facet = options.delete :facet

      filter = new_filter name, options, block

      facets[name] = filter if facet
      filters[name] = filter
    end

    private

    def new_filter( name, options, block )
      if select = options.delete(:select)
        raise ArgumentError, "no block allowed for select" if block
        select_filters = select.map{|name| filters[name] or raise ConfigurationError, "no filter for :select => #{name}"}
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

  end

  module InstanceMethods

    # attrs: <filter_name> => <value>, ...
    #        <order> => <filter_name>, :desc => true 
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
      @order = params.delete(:order)
      @desc = params.delete(:desc)
      raise ArgumentError, ':desc given but no :order' if @desc and not @order

      # find filters by name
      @filter_params = {}
      params.each do |name, value|
        filter = self.class.filters[name] or raise ArgumentError, "undefined filter #{name}" 
        @filter_params[filter] = value
      end
    end

    def scope
      scope = self.class.scope  
      @filter_params.each do |filter, value| 
        scope = filter.apply scope, value
      end
      if @order
        scope.order "#{@order} #{@desc ? 'DESC' : 'ASC'}" 
      else
        scope
      end
    end

    def facets
      self.class.facets.values.map do |filter|
        Facet.new filter, scope
      end
    end

  end

end
