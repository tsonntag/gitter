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
  
    def header_row
      @current_header_row = []
      yield
      (@header_rows||=[])+= [@current_header_row]
    end

    def header *args, &block 
      opts = args.extract_options!
      @current_header_row += [Header.new(self,args.first, block, opts)]
    end

    def column name, opts = {}, &block
      (@columns||= {})[name] = ColumnSpec.new self, name, opts, &block
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
        rows = @header_rows

        max = columns.map{|col|col.headers.size}.max

	columns_headers = columns.map{|col| Array.new(max){|i| col.headers[i] || Header.blank }}

	rows += columns_headers.transpose
      end
    end
 
    def row_for model
      columns.map{|c| c.cell model }.compact
    end
 
    def rows driver = self.scope 
      driver.map do |model| 
        @decorator.decorate model
        row_for model
      end
    end
 
    def columns
      @columns.values
    end

    private

    def initialize_columns
      if order = @params[:order]
        unless @order_column = @columns[:"#{order}"] 
          raise ArgumentError, "invalid order column #{order}"
        end 
      else
        @order_column = nil
        raise ArgumentError, ':desc given but no :order' if @params[:desc] 
      end
    end
 
   end
 
end
