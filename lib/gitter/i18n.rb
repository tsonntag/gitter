require 'i18n'

module Gitter
  module I18n

   def translate( prefix, key )
     ::I18n.translate "gitter.#{name}.#{prefix}.#{key}", :default => key.to_s.humanize
   end
 
  end
end
