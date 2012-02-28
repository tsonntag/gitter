require 'gitter/driver'
require 'gitter/base'
require 'gitter/columns'
require 'gitter/breadcrumbs'
require 'gitter/csv'
require 'gitter/i18n'
require 'gitter/helpers'

module Gitter

  class Grid
    include Base
    include Driver
    include Columns
    include Breadcrumbs
    include CSV
    include I18n
    include Helpers
  end

end
