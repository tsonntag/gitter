module Gitter

  class Railtie < Rails::Railtie
    config.after_initialize do 
      #ApplicationController.send :include, Gitter::Controller
    end
  end
end
