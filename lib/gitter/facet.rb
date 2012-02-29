require 'gitter/utils'

module Gitter

  class FacetData
    include Utils

    attr_reader :facet, :value, :count
    delegate :grid, :name, :to => :facet
    delegate :h, :to => :grid

    def initialize facet, value, count 
      @facet, @value, @count = facet, value, count 
    end

    def params
      { name => value }
    end

    def link
      h = grid.h
      p = grid.params.dup 
      p[name] = value.nil? ? '' : value
      p = grid.scoped_params p
      p[:page] = 1

      option_tag = h.content_tag :span, (value.nil? ? '-' : value), :class => 'facet_value'
      option_link = h.link_to option_tag, url_for(p)

      count_tag = h.content_tag :span, "(#{count})", :class => 'facet_count'
      count_link  = h.link_to count_tag,  url_for(p.merge(:show=>true))

      h.content_tag :span, (option_link + count_link), {:class => 'facet_entry'}, false
    end

    def to_s
      "#{name}:#{value}=#{count}"
    end

  end

  class Facet
    attr_reader :filter
    delegate :grid, :name, :to => :filter

    def initialize filter
      @filter = filter
    end

    def label
      filter.label or grid.translate(:facets, name)
    end

    def data opts = {}
      @data ||= begin
        value_to_count = filter.counts
        values = opts[:include_zeros] ? filter.distinct_values : value_to_count.keys
        values.map do |value|
          FacetData.new self, value, (value_to_count[value]||0)
        end
      end
    end

    def to_s
      "#{self.class}(#{name},label=#{label})"
    end
  end

end
