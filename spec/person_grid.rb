class PersonGrid
  include TracksGrid

  scope do
    Person.scoped
  end

  today = Time.utc(2011,01,01)

  filter :name
  filter :surname, :label => 'Surname'

  filter :birthday, :range => true

  filter :teen do |scope|
    scope.where :birthday => (today - 19.years...now - 10.years)
  end 

  filter :twen do |scope|
    scope.where :birthday => (today - 29.years...now - 20.years)
  end 

  filter :child do |scope|
    scope.where :birthday => (today - 10.years...now)
  end 

  filter :other do |scope|
    scope.where(':birthday >= ?', today - 18.years )
  end 

  filter :age, :select => [:child, :teen, :twen, :other]

  search :search_name, :columns => :name
  search :search, :columns => [:name, :surname]
  search :exact_search, :columns => :name, exact => true

end
