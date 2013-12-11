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

    def breadcrumbs_info
      @breadcrumbs_info ||= begin
        p = {}
        filters.inject({}) do |memo,filter|
          value = filter_value filter.name
          if value.present?
            p[filter.name] = value
            memo[filter.name] = { label: filter.label, value: value, url: url_for(scoped_params(p)) }
          end 
          memo
        end
      end
    end

    def render_breadcrumbs delim = '>', params = {}
      delim_tag = h.content_tag :span, delim, {class: 'breadcrumb_delim'}

      p = {}
      breadcrumbs = filters.map do |filter|
        value = filter_value filter.name
        if value.present?
          s =  h.content_tag :span, "#{filter.label}:", class: 'breadcrumb_key'
          s += h.content_tag :span, value,              class: 'breadcrumb_value'            
          p[filter.name] = value
          h.link_to s, url_for(scoped_params(p).merge(params))
        else
          nil
        end
      end.compact

      if breadcrumbs.present? 
        h.content_tag :span, breadcrumbs.join(delim_tag), {class: 'breadcrumbs'}, false
      else
        nil
      end
    end

  end

end
