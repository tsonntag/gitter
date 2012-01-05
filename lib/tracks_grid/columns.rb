require 'tracks_grid/column'
  
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
  
    module InstanceMethods
  
      def initialize( params = {} )
        super
        if order = params.delete(:order)
          @order_column = self.class.columns[:"#{order}"] or raise ArgumentError, "unknown order column #{order}"
        else
          @order_column = nil
          raise ArgumentError, ':desc given but no :order' if @desc
        end
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
  
      def total_entries
        @total_entries.total_entries
      end
  
      def headers
        @header ||= columns.map(&:header)
      end
  
      def row_for(model)
        columns.map do |column|
          column.render model, @view_context
        end
      end
  
      def rows( scope = self.scope_with_order )
        scope.map do |model|
          row_for model
        end
      end
  
      def columns
        @columns ||= self.class.columns.values
      end
  
    end
  
  end
end
