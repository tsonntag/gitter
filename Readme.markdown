# Tracksgrid

Ruby library for Rails which enables you to create

* Decorators / presenters for your models
* Data grids, i.e table like data with customizable
  * Filters
  * Sortables columns
  * Faceted search
  * Localization

## Decorators

* extend an object with given classes (default is \<object.class\>Decorator, if defined)
* make helpers accessible in object via :h

### Example

Decorate a model in your controller:

```ruby
  def show
    article = Article.find(params[:id])
    @article = TracksGrid::Decorator.decorate(article, self)
  end
```

Then @article will be extended by module ArticleDecorator
and has access to your helpers via :h

```ruby
module ArticleDecorator
  def image
    h.image_tag('article')
  end
end
```
and your views may use the decoratored model: 

```ruby
# app/views/articles/show.html.haml
%h1 
  Article
  = @article.image
```

[More about decorators](https://github.com/tracksun/tracksgrid/wiki/Decorators)

## Data Grids

In order to define a grid you need to provide:

* a scope which returns the objects for the grid's rows
* filters that will be used to filter the rows
* columns to be displayed

Example:

```ruby
class ArticleGrid << TracksGrid::Grid
   
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

[More about filters](https://github.com/tracksun/tracksgrid/wiki/Filters)

[More about columns](https://github.com/tracksun/tracksgrid/wiki/Columns)


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
[More about grids](https://github.com/tracksun/tracksgrid/wiki/Grids)

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
[More about facets](https://github.com/tracksun/tracksgrid/wiki/Facets)

# Breadcrumbs

Render your breadcrumbs:

```haml
@grid.render_breadcrumbs
```


[More about inputs](https://github.com/tracksun/tracksgrid/wiki/Inputs)



# ORM Support

* ActiveRecord
* others: Help or suggestions are welcome


# Credits

API inspired by [datagrid](https://github.com/bogdan/datagrid)

# License

TracksGrid is released under the MIT license
