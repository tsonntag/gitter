require 'active_support/concern'
  
module TracksGrid
  module Breadcrumbs
    extend ActiveSupport::Concern

    def breadcrumbs
      @breadcrumbs ||= begin
        p = {}
        text = @filters.map do |filter, value|
          p[filter.label] = value
        end
        p
      end
    end

    def render_breadcrumbs( join = '>' )
      @rendered_breadcrumbs ||= begin
        p = {}
        text = breadcrumbs.map do |label, value|
          s =  h.content_tag :span, "#{label} : ", :class => 'breadcrumb_key'
          s += h.content_tag :span, value,         :class => 'breadcrumb_value'            
          p[filter.name] = value
          h.link_to s, url_for(p)
        end.join(join)
        h.content_tag :span, text, {:class => 'breadcrumbs'}, false
      end
    end

  end

end
