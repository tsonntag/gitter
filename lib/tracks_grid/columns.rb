require 'active_support/concern'
require 'tracks_grid/columns/column'
require 'tracks_grid/columns/column_spec'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/array'
  
module TracksGrid
  module Columns
    extend ActiveSupport::Concern
  
    included do
      mattr_accessor :column_specs, :instance_reader => false, :instance_writer => false
      self.column_specs = {}

      after_initialize :initialize_columns
      alias_method_chain :ordered, :columns
    end
  
    module ClassMethods
      # adds a column to be display
      # Example:
      #
      # column(:birthday)
      # displays :birthday of the model
      #
      # A header may be specified by :header:
      #
      # column(:birthday, :header => 'Birthday'
      #
      # Supply a block to computed the column's data
      #
      # column(:year, :header => 'Year') do |model|
      #   model.birthday.strftime("%Y")
      # end
      #
      def column( name, opts = {}, &block )
        column_specs[name] = ColumnSpec.new name, opts, &block
      end
    end
  
    def ordered_with_columns
      @ordered ||= @order_column ? @order_column.ordered : ordered_without_columns
    end
 
    def paginate
      @paginate ||= ordered.paginate @paginate_hash
    end
 
    def headers
      @headers ||= column.map &:header
    end
 
    def row_for(model)
      columns.map{|c| c.cell model }
    end
 
    def rows( driver = self.ordered )
      driver.map{|model| row_for model}
    end
 
    def columns
      @columns ||= column_specs.map{|spec|Column.new spec, self}
    end

    def column_specs
      @column_specs ||= self.class.column_specs.values
    end
 
    private

    def initialize_columns
      if order = @params[:order]
        if spec = self.class.column_specs[:"#{order}"] 
          @order_column = Column.new spec, self
        else
          raise ArgumentError, "invalid order column #{order}"
        end 
      else
        @order_column = nil
        raise ArgumentError, ':desc given but no :order' if @params[:desc] 
      end

      @paginate_hash = { :per_page => @params.delete(:per_page){30}, :page => @params.delete(:page){1} }
    end
 
   end
 
end
