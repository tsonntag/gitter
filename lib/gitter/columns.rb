require 'active_support/concern'
require 'gitter/column'
require 'gitter/header'
require 'gitter/cell'
require 'active_support/benchmarkable'
require 'logger'

module Gitter
  module Columns
    include ActiveSupport::Benchmarkable
    extend ActiveSupport::Concern

    included do
      alias_method :scope_without_columns, :scope
      alias_method :scope, :scope_with_columns
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def header_row
      @current_header_row = []
      yield
      (@header_rows||=[]) << @current_header_row
    end

    def header *args
      @current_header_row << Header.new(self,*args)
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

    def rows_for model
#benchmark "---------rows_for #{model}" do
      cols = nil
      cols = columns.map do |c|
#  benchmark "cells for #{c.name}" do
        [c.cells(model)].flatten
#  end
      end
      max = cols.map{|col|col.size}.max

      cols.map do |col|
        nil_padded_cells = Array.new(max){|i| col[i]}
	cells = []
	nil_padded_cells.each_with_index do |c,i|
           unless c.nil?
             height = consecutive_count(nil_padded_cells.slice(i+1..-1), nil) + 1
             cells << Cell.new(c, rowspan: height)
	   else  # required for transpose
             cells << nil
	   end
	end
	cells
      end.transpose
#end
    end

    def rows scope = nil
      res = []
      models(scope||self.scope).each{|model| res += rows_for(model)}
      res
    end

    def models scope = self.scope
      if respond_to? :transform
        transform scope
      else
        scope
      end
    end

    def columns
      (@columns||={}).values
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

    def consecutive_count arr, what
      count = 0
      arr.each do |el|
        if el == what
          count +=1
	else
          break
	end
      end
      count
    end

   end

end
