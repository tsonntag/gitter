require 'action_view'

module Gitter

  class TableCell 

    attr_reader :x, :y, :content

    def initialize x, y, content
      @x, @y, @content = x, y, content
    end

    def html opts = {}
      Table.tag :td, content, opts.merge(class: "#{x} #{y}")
    end

    def header?
      false
    end
  end

  class TableHeaderCell < TableCell
    attr_reader :content

    def initialize content
      @content = content
    end

    def html opts = {}
      Table.tag :th, content, opts
    end

    def header?
      true
    end
  end

  class Table
    extend ActionView::Helpers::TagHelper
    extend ActionView::Helpers::OutputSafetyHelper
 
    def self.tag tag, content, opts = {}
      opts = opts.merge(class: "#{opts[:class]} grid pivot")
      content_tag tag, raw(content), opts
    end

    attr_reader :title, :x_axis, :y_axis, :data, :opts

    # axis: responds to each, yielding [key,title] or key 
    #   # data: hash from [x_key,y_key] to cell_array 
    def initialize title, x_axis, y_axis, data, opts = {}
      @title, @x_axis, @y_axis, @data, @opts = title, x_axis, y_axis, data, opts
      if label = opts[:show_sums]
        add_sums_to_cells data
        @x_axis = add_sums_to_axis @x_axis, label
        @y_axis = add_sums_to_axis @y_axis, label
      end
    end

    def rows
      @rows ||= begin
        rows = []
        rows << x_header if x_header

        rows + (y_axis||[nil]).map do |y,y_title|
           row = (x_axis||[nil]).map do |x,x_title|
             cell = data[pivot_key(x,y)]
             cell = yield cell, x, y if block_given?
             TableCell.new x, y, cell
	   end
           row.unshift TableHeaderCell.new(y_title||y) if y_axis
	   row
        end
      end 
    end

    def html
      @html ||= begin
        h = rows.map do |row|
          Table.tag :tr, (row.map{|cell| cell.html} * "\n")
        end * "\n"
	Table.tag :table, h
      end
    end

    private

    def x_header
      @x_header ||= begin 
        if x_axis
          h = x_axis.map{|key,title| TableHeaderCell.new(title||key) }
          h.unshift TableHeaderCell.new('') if y_axis
          h
        else
          nil 
        end
      end
    end

    def pivot_key x, y
      if x.nil? || y.nil?
        x.nil? ? y : x
      else
        [x,y]
      end
    end

    def add_sums_to_cells cells
      xcells, ycells = {}, {}
      sum = 0
      cells.each do |key,value|
        x, y = *key
        xcells[y] = (xcells[y]||0) + value
        ycells[x] = (ycells[x]||0) + value
        sum += value
      end
      xcells.each{|y,sum| cells[pivot_key(:sum,y)] = sum}
      ycells.each{|x,sum| cells[pivot_key(x,:sum)] = sum}
      cells[[:sum,:sum]] = sum
      cells
    end

    def add_sums_to_axis axis, label = nil
      label = 'Sum' unless String === label
      case axis
      when Array then axis + [[:sum, label]]
      when Hash  then axis.merge(:sum => label)
      else nil;
      end
    end

  end
end
