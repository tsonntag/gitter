module TracksGrid

  # scope = User.scoped
  #
  # f = Filter.new :active do |scope|
  #   scope.where( :status => 'active' )
  # end
  # 
  # f.apply( scope ) => scope.where( :status => 'active' )
  #
  class BlockFilter < AbstractFilter

     def initialize( name, options ={}, &block )
       raise ArgumentError, "no block given" unless block
       @block = block
       super name, options
     end

     def apply( scope, *args )
       @block.call scope, *args
     end

     def counts( scope )
       apply(scope).count
     end

  end
end
