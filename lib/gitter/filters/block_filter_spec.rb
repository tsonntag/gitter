module Gitter

  # scope = User.scoped
  #
  # f = Filter.new :active do |scope|
  #   scope.where( :status => 'active' )
  # end
  # 
  # f.apply( scope ) => scope.where( :status => 'active' )
  #
  class BlockFilterSpec < AbstractFilterSpec

     def initialize( name, options ={}, &block )
       raise ArgumentError, "no block given" unless block
       @block = block
       super name, options
     end

     def apply( driver, *args )
       opts = args.extract_options!

       raise ArgumentError, "too many arguments #{args.inspect}" unless args.size == 1
       value = args.first

       return driver if value.blank?

       driver.new @block.call(driver.scope, value)
     end
     
  end
end
