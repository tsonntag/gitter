load File.expand_path( '../../lib/tracks_grid.rb', __FILE__ )

class OrderPositionGrid
  include TracksGrid

  scope do 
    OrderPosition.scoped
  end 

  filter :order_date, :range => true

  filter :production, :label => 'Perso' do |scope|
    scope.where :order_type => %w(P PS) 
  end

  filter :shipment, :label => 'Ship' do |scope|
    scope.where :order_type => %w(S) 
  end

  filter :type, :label => 'Type', :select => [:production, :shipment], :facet => true

  filter :customer, :label => 'Customer', :facet => true

  search :search_text, :term, :columns => [ :order_no, :customer ]

  search :search_exact, :columns => :customer, :exact => true
end


