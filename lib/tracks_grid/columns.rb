require 'active_support/concern'
require 'tracks_grid/columns/column'
require 'tracks_grid/columns/column_desc'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/array'
  
module TracksGrid
  module Columns
    extend ActiveSupport::Concern
  
    included do
      self.class_attribute :column_descs, :instance_reader => false, :instance_writer => false
      self.column_descs = {}

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
        self.column_descs = self.column_descs.merge name => ColumnDesc.new(name, opts, &block)
      end
    end
  
    def ordered_with_columns
      @ordered_with_columns ||= @order_column ? @order_column.ordered : ordered_without_columns
    end
 
    def paginate
      @paginate ||= ordered.scope.paginate @paginate_hash
    end
 
    def headers
      @headers ||= columns.map &:header
    end
 
    def row_for(model)
      columns.map{|c| c.cell model }
    end
 
    def rows( driver = self.ordered )
      driver.map{|model| row_for model}
    end
 
    def columns
      @columns ||= self.column_descs.map{|desc| Column.new(self, desc) }
    end

    def column_descs
      @column_descs ||= self.class.column_descs.values
    end
 
    private

    def initialize_columns
      if order = @params[:order]
        if column_desc = self.class.column_descs[:"#{order}"] 
          @order_column = Column.new(self, column_desc)
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
