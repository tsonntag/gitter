module Gitter

  class BlockFilter < AbstractFilter

     def initialize grid, name, options ={}, &block
       raise ArgumentError, "no block given" unless block
       @block = block
       super grid, name, options
     end

     def apply driver, value = nil 
       driver.new @block.call(driver.scope, value)
     end
     
  end
end
