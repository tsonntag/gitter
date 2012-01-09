require 'tracks_grid/column'
require 'tracks_grid/column_spec'
require 'will_paginate'
require 'will_paginate/active_record'
  
module TracksGrid
  module Columns
    extend ActiveSupport::Concern
  
    included do
      mattr_accessor :column_specs, :instance_reader => false, :instance_writer => false
      self.column_specs = {}
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
  
    def initialize( *args )
       super 

       @desc = @params.delete(:desc)

       if order = @params.delete(:order)
         @order_column = self.class.column_specs[:"#{order}"] or raise ArgumentError, "unknown order column #{order}"
       else
         @order_column = nil
         raise ArgumentError, ':desc given but no :order' if @desc
       end

       @paginate_hash = { :per_page => @params.delete(:per_page){30}, :page => @params.delete(:page){1} }
     end
 
     def scope_with_order
       @scope_with_order ||= if @order_column
         @order_column.ordered scope, @desc
       else
         ordered
       end
     end
 
     def paginate
       @paginate ||= scope_with_order.paginate @paginate_hash
     end
 
     def headers
       @headers ||= column.map &:header
     end
 
     def row_for(model)
       columns.map{|c| c.cell model }
     end
 
     def rows( scope = self.scope_with_order )
       scope.map{|model| row_for model}
     end
 
     def columns
       @columns ||= column_specs.map{|spec|Column.new spec, self}
     end

     def column_specs
       @column_specs ||= self.class.column_specs.values
     end
 
   end
 
end
