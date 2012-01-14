# Tracksgrid

Ruby library for Rails which helps you to build

* decorators for your models
* Data grids, i.e table like data with customizable
  * Filters
  * Sortables columns
  * Faceted search
  * Localization

### decorator

```ruby
# in your controller
  def show
    article = Article.find(params[:id])
    @article = decorator.decorate(article, self)
  end
```

* Makes helpers accessible via @article.h
* Extends @article with a module ArticleDecorator if defined

```ruby
module ArticleDecorator
  def image
    h.image_tag('article')
  end
end
```

You may provide arbritary modules:

```ruby
def buy
  user = User.find(params[:id])
  @buyer = decorator.decorate(user, UserView, BuyerView)
end
```

[More about decorators](https://github.com/tracksun/tracksgrid/wiki/Decorators)

### Data Grids

In order to define a grid you need to provide:

* scope of objects to look through
* filters that will be used to filter data
* columns to be displayed

Example:

```ruby
class ArticleGrid << TracksGrid::Grid
   
  ### First define the source for your data
  scope do
    Article.where(:owner => h.current_user)
  end
     
  ### You may define filters 

  # filter by attribute:
  filter :name
  
  # filter by multiple columns: filters by :name OR :description
  filter :search, :columns => [:name, :description]

  # customized filter 
  filter :on_stock, :facet => true do |scope|
    scope.where(:stock > 0)
  end
  
  # filter by named scope
  filter :topsellers, :scope => :topsellers
     
  # add to facets
  filter :category, :facet => true              
  
  # select among named scopes
  filter :price_range, :scopes => [:niceprice, :regular] 


  ### Define your data  grid

  # show an attribute
  column :article_no
  
  # provide a explicite header
  column :description, :header => 'Details'

  # make column sortable
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
[More about columns](https://github.com/tracksun/tracksgrid/wiki/Filters)


Using your grid:

Using your filters:

@grid = Article.new(:params => {:name => 'VW Beetle'})

In order to get access to the helpers, you must provide an object
that quacks like Rails' view_context:

@grid = Article.new(:params => {:name => 'VW Beetle'}, :view_context => view_context)

For the most common use case -- in your controller -- things get simple:

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



[More about inputs](https://github.com/tracksun/tracksgrid/wiki/Inputs)



### ORM Support

* ActiveRecord
* others: Help or suggestions are welcome


### Credits

[API inspired by](https://github.com/bogdan/datagrid)

### License

TracksGrid is released under the MIT license
