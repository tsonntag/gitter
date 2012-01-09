require 'tracks_grid/column'
require 'will_paginate'
require 'will_paginate/active_record'
  
module TracksGrid
  module Columns
    extend ActiveSupport::Concern
  
    included do
      mattr_accessor :columns, :instance_reader => false, :instance_writer => false
      self.columns = {}
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
        columns[name] = Column.new name, opts, &block
      end
    end
  
    def initialize( params = {} )
       @desc = params.delete(:desc)

       if order = params.delete(:order)
         @order_column = self.class.columns[:"#{order}"] or raise ArgumentError, "unknown order column #{order}"
       else
         @order_column = nil
         raise ArgumentError, ':desc given but no :order' if @desc
       end

       @paginate_hash = { :per_page => params.delete(:per_page){30}, :page => params.delete(:page){1} }
       super 
     end
 
     def scope_with_order
       @scope_with_order ||= if @order_column
         @order_column.ordered scope, @desc
       else
         scope
       end
     end
 
     def paginate
       @paginate ||= scope_with_order.paginate @paginate_hash
     end
 
     def headers
       @headers ||= columns.map(&:header)
     end
 
     def row_for(model)
       columns.map do |column|
         column.render model, @view_context
       end
     end
 
     def rows( scope = self.scope_with_order )
       scope.map{|model| row_for model}
     end
 
     def columns
       @columns ||= self.class.columns.values
     end
 
   end
 
end
