require 'active_support/concern'
  
module Gitter
  module Breadcrumbs
    include Utils

    extend ActiveSupport::Concern

    def breadcrumbs
      @breadcrumbs ||= begin
        p = {}
        text = filters.map do |filter|
          p[filter.label] = filter_value(filter.name)
        end
        p
      end
    end

    def render_breadcrumbs delim = '>'
      delim_tag = h.content_tag :span, delim, {:class => 'breadcrumb_delim'}

      @rendered_breadcrumbs ||= begin
        p = {}
        text = filters.map do |filter|
          value = filter_value filter.name
          if value.present?
            s =  h.content_tag :span, "#{filter.label} : ", :class => 'breadcrumb_key'
            s += h.content_tag :span, value,                :class => 'breadcrumb_value'            
            p[filter.name] = value
            h.link_to s, url_for(p)
          else
            nil
          end
        end.compact.join(delim_tag)
        h.content_tag :span, text, {:class => 'breadcrumbs'}, false
      end
    end

  end

end
