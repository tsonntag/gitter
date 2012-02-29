require 'active_support/concern'
require 'gitter/column'
require 'gitter/header'
  
module Gitter
  module Columns
    extend ActiveSupport::Concern
  
    included do
      alias_method_chain :scope, :columns
    end
  
    def header_row
      @current_header_row = []
      yield
      (@header_rows||=[]) << @current_header_row
    end

    def header *args, &block 
      opts = args.extract_options!
      @current_header_row << Header.new(self,args.first, block, opts)
    end

    def column name, opts = {}, &block
      (@columns||= {})[name] = Column.new self, name, opts, &block
    end
  
    def scope_with_columns &scope
      if scope
        scope_without_columns &scope
      else
        @scope_with_columns ||= order_column ? order_column.ordered.scope : scope_without_columns
      end
    end
 
    def paginate *args 
      scope.paginate *args
    end
 
    def header_rows
      @all_header_rows ||= begin
        rows = @header_rows || []
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

    def order_column
      @order_column ||= begin
	if order = @params[:order]
          @columns[:"#{order}"] or raise ArgumentError, "invalid order column #{order}"
        else
          raise ArgumentError, ':desc given but no :order' if @params[:desc] 
          nil
        end
      end
    end

   end
 
end
