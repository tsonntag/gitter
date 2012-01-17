module Ranges

  def range_filter( name, options )
    column = options.delete(:column){name}

    filter options.delete(:from){:"from_#{name}"}, options do |scope, value|
      driver.new(scope).greater_or_equal(column, value).scope
    end

    filter options.delete(:to){:"to_#{name}"}, options do |scope, value|
      driver.new(scope).less_or_equal(column, value).scope
    end

    #filter name, :column => column
  end
  
end
