require 'gitter/driver'
require 'gitter/base'
require 'gitter/pivot'
require 'gitter/breadcrumbs'
require 'gitter/csv'
require 'gitter/i18n'
require 'gitter/helpers'
require 'gitter/model'

module Gitter

  class PivotGrid
    include Gitter::Base
    include Gitter::Driver
    include Gitter::Pivot
    include Gitter::Breadcrumbs
    include Gitter::CSV
    include Gitter::I18n
    include Gitter::Helpers
    include Gitter::Model
  end

end
