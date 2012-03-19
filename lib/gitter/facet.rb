require 'gitter/utils'

module Gitter

  class FacetData
    include Utils

    attr_reader :facet, :raw_value, :count
    delegate :grid, :name, to: :facet
    delegate :h, to: :grid

    def initialize facet, raw_value, count 
      @facet, @raw_value, @count = facet, raw_value, count 
    end

    def value
      @value ||= facet.format raw_value
    end

    def params
      @params ||= grid.scoped_params name => raw_value
    end

    def selected?
      @selected ||= facet.selected_value == raw_value.to_s
    end

    def link
      @link ||= begin
        p = grid.params.dup 
        p.delete name
        p[name] = raw_value if raw_value.present?
        p = grid.scoped_params p
        p[:page] = 1

        value_class = selected? ? 'facet_value_selected' : 'selected' 
        value_tag = h.content_tag :span, (raw_value.nil? ? '-' : raw_value), class: value_class
        value_tag = h.link_to value_tag, url_for(p)

        if selected? or not facet.selected?
          count_tag = h.content_tag :span, "(#{count})", class: 'facet_count'
          count_tag = h.link_to count_tag,  url_for(p.merge(show: true))
        else
          count_tag = ''
        end

        h.content_tag :span, (value_tag + count_tag), {class: 'facet_entry'}, false
      end
    end

    def to_s
      "#{name}:#{value}(#{raw_value})=#{count}"
    end

  end

  class Facet
    attr_reader :filter
    delegate :grid, :name, :selected_value, :selected?, :format, to: :filter

    def initialize filter
      @filter = filter
    end

    def label
      filter.label or grid.translate(:facets, name)
    end

    def params_for_any
      grid.scoped_params grid.params.reject{|k,v| k == name}
    end

    def selected_data opts = {}
      data(opts).detect{|d|d.selected?}
    end

    def data opts = {}
      values_to_counts = filter.counts
      values = opts[:include_zeros] ? filter.distinct_values(grid.driver) : values_to_counts.keys
      values.map do |value|
        FacetData.new self, value, (values_to_counts[value]||0)
      end
    end

    def to_s
      "#{self.class}(#{name},label=#{label})"
    end
  end

end
