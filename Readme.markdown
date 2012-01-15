# Tracksgrid

Ruby library for Rails which enables you to create

* Decorators or presenters for your models
* Data grids, i.e table like data with customizable
  * Filters
  * Sortables columns
  * Faceted search
  * Localization

## Decorators

A Decorator

* Extends an object with given classes (default is <object.class>Decorator, if it is defined)
* Makes helpers accessible in object via :h

Example:

Decorate a model in your controller:

```ruby
  def show
    article = Article.find(params[:id])
    @article = Decorator.decorate(article, self)
  end
```

Then @article will be extended by

```ruby
module ArticleDecorator
  def image
    h.image_tag('article')
  end
end
```


You may provide arbritary modules:

```ruby
# in your controller
def buy
  user = User.find(params[:id])
  @buyer = Decorator.decorate(user, UserView, Buyer)
end
```
with

```ruby
module UserViews
  def view
    "#{name} #{surname}"
  end
end
```
and

```ruby
module UserViews
  def buy(item)
    #.....
  end
end
```

[More about decorators](https://github.com/tracksun/tracksgrid/wiki/Decorators)

## Data Grids

In order to define a grid you need to provide:

* scope which returns the objects for the grid's rows
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
    scope.where(:stock > 0)
  end

 filter :out_of_stock do |scope|
    scope.where(:stock = 0)
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
  # The header of this columns is looked in  from 'tracksgrid.article_grid.headers.acticle_no'
  column :article_no
  
  # provide a hardcoded header
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


#Using your grid

For the most common use case -- your controller -- you simply do:

```ruby
def index
  @grid = ArticleGrid.new(self)
end
```

In your views (haml for readabilty)

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
@grid.breadcrumbs
```


[More about inputs](https://github.com/tracksun/tracksgrid/wiki/Inputs)



### ORM Support

* ActiveRecord
* others: Help or suggestions are welcome


### Credits

[API inspired by datagrid](https://github.com/bogdan/datagrid)

### License

TracksGrid is released under the MIT license
