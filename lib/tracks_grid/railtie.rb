module TracksGrid

  class Railtie < Rails::Railtie
    config.after_initialize do 
      #ApplicationController.send :include, TracksGrid::Controller
    end
  end
end
