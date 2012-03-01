require 'gitter/driver'
require 'gitter/base'
require 'gitter/columns'
require 'gitter/breadcrumbs'
require 'gitter/csv'
require 'gitter/i18n'
require 'gitter/helpers'
require 'gitter/model'

module Gitter

  class Grid
    include Gitter::Base
    include Gitter::Driver
    include Gitter::Columns
    include Gitter::Breadcrumbs
    include Gitter::CSV
    include Gitter::I18n
    include Gitter::Helpers
    include Gitter::Model
  end

end
