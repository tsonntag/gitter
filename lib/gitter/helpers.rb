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

    def mark *keys
      { mark: keys.map{|k|filter_value k}.select{|v|v.present?} }
    end

    def highlight text, *keys
      h.highlight "#{text}", mark(*keys)[:mark] 
    end

    def h
      @decorator.h
    end

    def input_tags
      @input_tags ||= begin
        res = {}
        filters.each do |filter|
          res[filter.name] = filter.input_tag if filter.input?
        end
        res
      end
    end

  end
end
