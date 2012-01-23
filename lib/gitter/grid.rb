require 'gitter/driver'
require 'gitter/base'
require 'gitter/columns'
require 'gitter/breadcrumbs'
require 'gitter/csv'

module Gitter

  class Grid
    include Base
    include Driver
    include Columns
    include Breadcrumbs
    include CSV
  end

end
