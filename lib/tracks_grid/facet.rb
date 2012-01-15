module TracksGrid

  class FacetData
    attr_reader :facet, :value, :count
    delegate :grid, :name, :to => :facet

    def initialize( facet, value, count )
      @facet, @value, @count = facet, value, count 
    end

    def params
      { name => value }
    end

    def link
      p = grid.h.request.query_parameters
      p.delete(:show)
      p[name] = value.nil? ? '' : value
      p[:page] = 1

      option_tag = h.content_tag :span, (value.nil? ? '-' : value), :class => 'facet_value'
      option_link = h.link_to option_tag, grid.url_for(p)

      count_tag = h.content_tag :span, "(#{count})", :class => 'facet_count'
      count_link  = h.link_to count_tag,  grid.url_for(p.merge(:show=>true))

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
    attr_reader :filter, :grid
    delegate :name, :label, :to => :filter

    def initialize( grid, filter )
      @grid, @filter = grid, filter
    end

    def data
      @data ||= filter.counts(grid.driver).map{|value, count| FacetData.new self, value, count}
    end

    def to_s
      "#{self.class}(#{name},label=#{label})"
    end
  end

end
