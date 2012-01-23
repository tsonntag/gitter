# gitter

Ruby library for Rails which enables you to create
data grids, i.e table like data with customizable

  * Filters
  * Sortables columns
  * Faceted search
  * Localization

## Data Grids

In order to define a grid you need to provide:

* a scope which returns the objects for the grid's rows
* filters that will be used to filter the rows
* columns to be displayed

Example:

```ruby
class ArticleGrid << Gitter::Grid
   
  ### First define the source for your data
  # helpers are accessible by #h
  scope do
    Article.where(:owner => h.current_user)
  end
     
  ### Then you may define filters

  # filter by attribute
  filter :name
  
  # filter by multiple columns: filters by :name OR :description
  filter :search, :columns => [:name, :description]

  # filter by named scope
  filter :topsellers, :scope => :topsellers

  # customized filter 
  filter :on_stock, do |scope|
    scope.where('stock > 0')
  end

  filter :out_of_stock do |scope|
    scope.where(:stock => 0)
  end
  
  # select from given filters
  filter :availability, :select => [:on_stock, :out_of_stock]
    
  # add to facets
  filter :category, :facet => true              
  
  # select among named scopes
  filter :price_range, :scopes => [:niceprice, :regular] 

  # you can provide 'search' like attributes
  filter :search, :ignore_case => true, :exact => false
  
  # The former can be abbreviated by
  search :search

  ### Define your data grid

  # show an attribute
  column :article_no
  
  # provide a hardcoded header (i18n support also available)
  column :description, :header => 'Details'

  # make the column sortable
  column :name, :sort => true     

  # customize your data cell
  column :price, :sort => true do
    "#{price/100.floor},#{price%100} USD"
  end
  
  # helpers are accessible via #h
  column :details, :header => false do
    h.link_to 'details', h.edit_article_path(self)
  end
  
end
```

[More about filters](https://github.com/tracksun/gitter/wiki/Filters)

[More about columns](https://github.com/tracksun/gitter/wiki/Columns)


#Rendering your grid

For the most common use case -- your controller -- you simply do:

```ruby
def index
  @grid = ArticleGrid.new(self)
end
```

Render you grid:

```haml
%table
  %tr
    - @grid.headers.each do |header|
    %th = header

  - @grid.rows.each do |row|
    %tr
      - row.each do |cell|
      %th = cell 
```
[More about grids](https://github.com/tracksun/gitter/wiki/Grids)

# Facets

Render your facets:

```haml
%ul
  - @grid.facets do |facet|
    %li
      = facet.label
      %ul
        - facet.data.each do |data|
          = data.value
          = link_to "(#{data.count})", data.link

```
[More about facets](https://github.com/tracksun/gitter/wiki/Facets)

# Breadcrumbs

Render your breadcrumbs:

```haml
@grid.render_breadcrumbs
```


[More about inputs](https://github.com/tracksun/gitter/wiki/Inputs)



# ORM Support

* ActiveRecord
* others: Help or suggestions are welcome


# Credits

API inspired by [datagrid](https://github.com/bogdan/datagrid)

# License

Gitter is released under the MIT license
