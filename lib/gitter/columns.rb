require 'active_support/concern'
require 'gitter/column'
require 'gitter/column_spec'
require 'gitter/header'
require 'gitter/header_spec'
  
module Gitter
  module Columns
    extend ActiveSupport::Concern
  
    included do
      self.class_attribute :column_specs, :instance_reader => false, :instance_writer => false
      self.class_attribute :header_specs_rows, :instance_reader => false, :instance_writer => false
      self.class_attribute :current_header_specs_row, :instance_reader => false, :instance_writer => false
      self.column_specs = {}
      self.header_specs_rows = [] 

      after_initialize :initialize_columns
      alias_method_chain :scope, :columns
    end
  
    module ClassMethods

      def header_row
        self.current_header_specs_row = []
	yield
        self.header_specs_rows += [self.current_header_specs_row]
      end

      def header *args, &block 
        opts = args.extract_options!
	self.current_header_specs_row += [HeaderSpec.new(args.first, block, opts)]
      end

      # adds a column to be displayed
      #
      # Example:
      #
      # column :birthday 
      # displays :birthday of the model
      #
      # A header may be specified by :header:
      #
      # column :birthday, :header => 'Birthday'
      #
      # Supply a block to computed the column's data
      #
      # column(:year, :header => 'Year') do |model|
      #   model.birthday.strftime("%Y")
      # end
      #
      def column name, opts = {}, &block
        self.column_specs = self.column_specs.merge(name => ColumnSpec.new(name, opts, &block))
      end
    end
  
    def scope_with_columns
      @scope_with_columns ||= @order_column ? @order_column.ordered.scope : scope_without_columns
    end
 
    def paginate *args 
      @paginate ||= scope.paginate *args
    end
 
    def header_rows
      @header_rows ||= begin
        rows = self.class.header_specs_rows.map do |header_specs_row|
          header_specs_row.map{|header_spec| Header.new self, header_spec}
	end

        max = columns.map{|col|col.headers.size}.max

	columns_headers = columns.map{|col| Array.new(max){|i| col.headers[i] || Header.blank }}

	rows += columns_headers.transpose
      end
    end
 
    def row_for model
      columns.map{|c| c.cell model }
    end
 
    def rows driver = self.scope 
      driver.map do |model| 
        @decorator.decorate model
        row_for model
      end
    end
 
    def columns
      @columns ||= self.class.column_specs.map{|name, spec| Column.new(self,spec) }
    end

    private

    def initialize_columns
      if order = @params[:order]
        if column_spec = self.class.column_specs[:"#{order}"] 
          @order_column = Column.new self, column_spec 
        else
          raise ArgumentError, "invalid order column #{order}"
        end 
      else
        @order_column = nil
        raise ArgumentError, ':desc given but no :order' if @params[:desc] 
      end
    end
 
   end
 
end
