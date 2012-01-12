require 'active_support/concern'
  
module TracksGrid
  module Breadcrumbs
    extend ActiveSupport::Concern
  
    def breadcrumbs( join = '>' )
      @breadcrumbs ||= begin
        p = {}
        text = @filter_params.map do |filter, value|
          s =  h.content_tag :span, "#{filter.label} : ", :class => 'search_key'
          s += h.content_tag :span, value,                :class => 'search_value'
          p[filter.name] = value
          h.link_to s, url_for(p)
        end.join(join)
        h.content_tag :span, text, {:class => 'search_titles'}, false
      end
    end
 
  end
 
end
