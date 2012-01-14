require 'tracks_grid/filters/filter'
require 'tracks_grid/filters/abstract_filter_spec'
require 'tracks_grid/filters/block_filter_spec'
require 'tracks_grid/filters/select_filter_spec'

if Model.const_defined? :ActiveRecord
  require 'tracks_grid/filters/active_record/ranges'
  require 'tracks_grid/filters/active_record/column_filter_spec'
end