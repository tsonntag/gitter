module Gitter
  
  module Pivot

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
        @drill_down ||= [names].flatten.map do |name| 
          filter = @filters[name] or raise ConfigurationError, "unknown filter #{name}"
          Facet.new filter
	end
      else
        @drill_down ||= @filters.map{|f|Facet.new f}
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
  
    private
    def data_scope
      @data_scope ||= scope.group(x_axis.attr).group(y_axis.attr)
    end
  
  end
end
