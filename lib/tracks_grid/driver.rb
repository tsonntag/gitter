require 'active_support/concern'

module TracksGrid
  module Driver
    extend ActiveSupport::Concern
  
    module ClassMethods
      def driver_class( driver_class = nil )
        if driver_class
          @driver_class = driver_class
        else
          @driver_class || detect_driver_class or raise ConfigurationError, "no driver given"
        end
      end

      def driver( scope = self.scope )
        self.driver_class.new(scope)
      end

      private
      def detect_driver_class
        case
        when Module.const_defined?(:ActiveRecord)
          require 'tracks_grid/drivers/active_record_driver'
          ActiveRecordDriver
        end
      end
    end

  end
end
