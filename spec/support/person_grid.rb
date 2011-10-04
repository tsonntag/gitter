class PersonGrid
  include TracksGrid

  scope do
    Person.scoped
  end

  today = Time.utc(2011,01,01)

  filter :name, :facet => true
  filter :surname, :label => 'Surname'

  filter :birthday, :range => true

  filter :teen do |scope|
    scope.where :birthday => (today - 19.years...today - 10.years)
  end 

  filter :twen do |scope|
    scope.where :birthday => (today - 29.years...today - 20.years)
  end 

  filter :child do |scope|
    scope.where :birthday => (today - 10.years...today)
  end 

  filter :other do |scope|
    scope.where(':birthday >= ?', today - 18.years )
  end 

  filter :age, :select => [:child, :teen, :twen, :other], :facet => true

  search :search, :columns => [:name, :surname]
  search :search_name,                 :columns => :name
  search :search_name_ignore,          :columns => :name, :ignore_case => true
  search :search_name_no_ignore,       :columns => :name, :ignore_case => false
  search :search_name_exact,           :columns => :name, :exact => true
  search :search_name_exact_ignore,    :columns => :name, :exact => true, :ignore_case => true
  search :search_name_exact_no_ignore, :columns => :name, :exact => true, :ignore_case => false

end
