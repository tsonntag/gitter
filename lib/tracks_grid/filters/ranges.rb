module Ranges

  def range_filter( name, options )
    column = options.delete(:column){name}

    filter options.delete(:from){:"from_#{name}"}, options do |scope, value|
      Driver.new(scope).greater_or_equal column, value
    end

    filter options.delete(:to){:"to_#{name}"}, options do |scope, value|
      Driver.new(scope).less_or_equal column, value
    end

    filter name, :column => column
  end
  
end
