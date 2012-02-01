require 'active_support/concern'
  
module Gitter
  module Breadcrumbs
    include Utils

    extend ActiveSupport::Concern

    def breadcrumbs
      @breadcrumbs ||= begin
        p = {}
        text = @filters_values.map do |filter, value|
          p[filter.label] = value
        end
        p
      end
    end

    def render_breadcrumbs( join = '>' )
      @rendered_breadcrumbs ||= begin
        p = {}
        text = @filters_values.map do |filter, value|
          if value.present?
            s =  h.content_tag :span, "#{filter.label} : ", :class => 'breadcrumb_key'
            s += h.content_tag :span, value,                :class => 'breadcrumb_value'            
            p[filter.name] = value
            h.link_to s, url_for(p)
          else
            nil
          end
        end.compact.join(join)
        h.content_tag :span, text, {:class => 'breadcrumbs'}, false
      end
    end

  end

end
