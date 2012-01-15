require 'active_support/concern'
  
module TracksGrid
  module Driver
    extend ActiveSupport::Concern
  
    included do
      mattr_accessor :driver_class, :instance_reader => false, :instance_writer => false
    end
  
    module ClassMethods
      def driver_class( driver_class )
        if driver_class
          self.driver_class = driver_class
        else
          self.driver_class || detect_driver_class
        end
      end
      
      private
      def detect_driver_class
        case
        when Module.const_defined? :ActiveRecord
          require 'tracks_grid/drivers/active_record_driver'
          ActiveRecordDriver
        # add more drivers here
        else
          raise 'no driver'
        end
      end
    end
        
  end
end
