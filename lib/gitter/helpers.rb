module Gitter
  module Helpers

    def name
      @name ||= self.class.name.underscore
    end

    # used to scope params of requests 
    def key
      @key ||= name.intern
    end

    def scoped_params params
      { key => params }
    end

    def highlight text, *keys
      matches = keys.map{|k|params[k]}.select{|v|v.present?}
      text = "#{text||''}"
      if matches.empty?
        text
      else
        h.highlight text, matches
      end
    end

    def h
      @decorator.h
    end

    def input_tags
      @input_tags ||= begin
        res = {}
        filters.each do |filter|
          if i = filter.input_tag
            res[filter.name] = i
          end
        end
        res
      end
    end

  end
end
