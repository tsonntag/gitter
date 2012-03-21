module Gitter
  
  module Pivot

    def pivot_cells *groups
      opts = groups.extract_options!
      sum = opts[:sum]
      count = opts[:count]; count = :id if count == true

      groups = [groups].flatten

      cells = self.scope
      groups.each{ |g| cells = cells.group(g)}
      cells = cells.sum(sum) if sum
      cells = cells.count(:id) if count
      cells
    end

    def x_axis *args
      if args.present?
        @x_axis = Axis.new self, *args 
      else
        @x_axis or raise ConfigurationError, 'undefined x_axis'
      end
    end 

    def y_axis *args
      if args.present?
        @y_axis = Axis.new self, *args 
      else
        @y_axis or raise ConfigurationError, 'undefined y_axis'
      end
    end 

    def cell &cell 
      if cell
        @cell ||= cell
      else
        @cell or raise ConfigurationError, 'undefined cell'
      end
    end
  
    def drill_down *names
      if names.present?
        @drill_down ||= facet_for names
      else
        @drill_down ||= @filters.keys
      end
    end

    def input_tags
      []
    end
  
    def columns
      @columns ||= x_axis.titles.map{|x|Column.new self, x} 
    end

    def header_rows
      @header_rows ||= begin
        row = [''] + x_axis.titles
        row = row.map{|h|Gitter::Header.new self, h}
        [row]
      end
    end
  
    def rows scope = self.scope
      y_axis.data_titles.map do |y,y_title|
        row = []
        row << Gitter::Cell.new(y_title)
        row += x_axis.data.map do |x|
          content = cell.call data_scope, x, y
          Gitter::Cell.new content
        end
      end
    end

    # returns [ down, current, ups ]
    def drill_down_facets
      drill = drill_down.reverse
      i = drill.find_index{|f|f.selected?}
      if i == 0
        down = nil
	current, *ups = drill[0..-1]
      else
        down, current, *ups = drill[i-1..-1]
      end

      [ down, current, ups ]
    end

    private
    def data_scope
      @data_scope ||= scope.group(x_axis.attr).group(y_axis.attr)
    end

    def facet_for arg
      if arg.respond_to? :map
         arg.map{|a|facet_for a}
      else
        filter = @filters[arg] or raise ConfigurationError, "unknown filter #{arg}"
	Facet.new filter
      end
    end

  end
end
