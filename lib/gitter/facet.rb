require 'tracks_grid/utils'

module TracksGrid

  class FacetData
    include Utils

    attr_reader :facet, :value, :count
    delegate :grid, :name, :to => :facet

    def initialize( facet, value, count )
      @facet, @value, @count = facet, value, count 
    end

    def params
      { name => value }
    end

    def link
      h = grid.h
      p = h.request.query_parameters
      p.delete(:show)
      p[name] = value.nil? ? '' : value
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

    private
    def h
      grid.h
    end

  end

  class Facet
    attr_reader :grid, :filter_spec
    delegate :name, :to => :filter_spec

    def initialize( grid, filter_spec )
      @grid, @filter_spec = grid, filter_spec
    end

    def label
      filter_spec.label or grid.translate(:facets, name)
    end

    def data( *args )
      opts = args.extract_options!
      raise ArgumentError, 'too many arguments' if args.size > 1
      driver = args.first || grid.filtered_driver
      @data ||= begin
        value_to_count = filter_spec.counts(driver)
        values = opts[:include_zeros] ? filter_spec.distinct_values(driver) : value_to_count.keys
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
