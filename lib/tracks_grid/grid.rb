require 'tracks_grid/base'
require 'tracks_grid/columns'
require 'tracks_grid/breadcrumbs'
  
module TracksGrid

  class Grid
    include Base
    include Columns
    include Breadcrumbs
  end

end
