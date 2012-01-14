require 'tracks_grid/filters/abstract_filter'
require 'tracks_grid/filters/block_filter'
require 'tracks_grid/filters/select_filter'

if Model.const_defined? :ActiveRecord
  require 'tracks_grid/filters/active_record/range_filter'
  require 'tracks_grid/filters/active_record/column_filter'
end