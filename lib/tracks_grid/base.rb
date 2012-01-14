require 'active_support/concern'
require 'active_model/callbacks'
  
module TracksGrid

  module Base
    extend ActiveSupport::Concern

    included do 
      extend ActiveModel::Callbacks
      define_model_callbacks :initialize
      self.mattr_accessor :filters, :facets, :instance_reader => false, :instance_writer => false
      self.filters = {}
      self.facets = []
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

      def order( order = nil )
        order ? (@order = order) : @order
      end

      # Examples:
      #
      # Simple column filter: 
      #
      # class UserGrid << TracksGrid::Grid
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
      # Use :scope to filter by a given scope
      #
      # class User < ActiveRecord::Base
      #   scope :children, lambda{ where "birthday > :date", :date => 10.years.ago} 
      # end
      #
      #  filter :scope => :children
      # 
      # Use :scopes to select scopes
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
  
        filter = case
        when block 
          BlockFilter.new name, options, &block
        when options[:range]
          return range_filter(name, options) # return is required
        when s = options[:select]
          f = [s].flatten.map{|name| filters[name] or raise ConfigurationError, "no filter for :select => #{name}"}
          SelectFilter.new name, f, options
        when s = options[:scope]
          scope_filter( name || s, options )
        when s = options[:scopes]
          f = [s].flatten.map{|name| scope_filter name}
          SelectFilter.new name, f, options
        else 
          ColumnFilter.new name, options
        end
  
        facets << filter if options[:facet]
        filters[name] = filter
      end
  
      # shortcut for filter name, { :exact => false, :ignore_case => true }.merge(options)
      def search( name, options = {} )
        filter name, { :exact => false, :ignore_case => true }.merge(options)
      end
  
      private
  
      def scope_filter( name, options = {} )
        BlockFilter.new(name, options){|scope| scope.send name}
      end
  
  
      def check_opts( opts )
        raise ConfigurationError, "invalid opts #{opts.inspect}" unless opts.empty?
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
    #presenter
    #
    # Args may be either the params hash of the request
    # or an object which responds to :params and optionaly to :view_context, e.g. a controller instance
    def initialize( *args )
      run_callbacks :initialize do
        @presenter = Presenter.new args
        @params = @presenter.params

        @scope = @params.delete :scope
        @ordered = @params.delete :ordered
  
        @filter_params = {}
        @params.each do |name, value|
          if filter = self.class.filters[name] 
            @filter_params[filter] = value
          end
        end
      end
    end
  
    def scope
      @scope ||= begin
        scope = eval self.class.scope
        @filter_params.each{|filter, value| scope = filter.apply(scope, value, @params) }
        scope
      end
    end

    # returns scope which default order
    def ordered
      @ordered ||= if self.class.order && scope.respond_to?(:order)
        scope.order self.class.order
      else
        scope
      end
    end

    def facets
      @facets ||= self.class.facets.map{ |filter| Facet.new self, filter }
    end
  
    # evaluate data (string or proc) in context of grid
    def eval( data, model = nil )
      @presenter.eval data, model
    end

    # dirty hack to avoid rails' sorted query in url
    def url_for( params )
      p = params.dup 
      query = p.map{|key, value| value.to_query(key) } * '&'
      "#{h.url_for({})}?#{query}"
    end

    def inputs
      @inputs ||= begin
        res = {} 
        self.class.filters.each do |name, filter|
          if i = filter.input(@presenter)
            res[name] = i
          end
        end 
        res
      end
    end 
  end
end
