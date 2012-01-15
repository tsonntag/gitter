module TracksGrid
  class Driver
    
    def initialize( scope )
      if Module.const_defined? :ActiveRecord
        require 'tracks_grid/drivers/active_record_driver'
        ActiveRecordDriver.new scope
      else
        raise 'no driver'
      end
    end
  end
end