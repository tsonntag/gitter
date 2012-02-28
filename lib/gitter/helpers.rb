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
      h.highlight text.to_s||'', keys.map{|k|params[k]}.compact
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
