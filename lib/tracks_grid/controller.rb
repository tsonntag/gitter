module TracksGrid

  module Controller
    def tracks_grid( clazz )
      clazz.new params.merge( :view_context => view_context )
    end

    def method_missing( name, *args )
      if name.to_s =~ /.*_grid$/
         puts "DDDDDDDDDDDDDDDD #{name}, self.class=#{self.class}"

         self.class.class_eval <<-EOS 
           def #{name}
             tracks_grid #{name.to_s.camelcase} 
           end

           helper_method :#{name}
         EOS

         methods=self.class.new.methods.grep name
         puts "DDDDDDDDDDDDDDDXXX methods=#{methods*"\n"}"

         self.send name
      else
         super
      end
    end
  end 

end
