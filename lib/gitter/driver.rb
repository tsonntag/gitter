module Gitter
  module Driver
  
    def driver_class  driver_class = nil
      if driver_class
        @driver_class = driver_class
      else
        @driver_class || detect_driver_class or raise ConfigurationError, "no driver given"
      end
    end

    def create_driver scope
      driver_class.new scope
    end

    private
    def detect_driver_class
      case
      when Module.const_defined?(:ActiveRecord)
        require 'gitter/drivers/active_record_driver'
        ActiveRecordDriver
      end
    end

  end
end
