class PersonGrid < Gitter::Grid

  scope do
    Person.scoped
  end

  today = Time.utc(2011,01,01)

  filter :name, :facet => true
  filter :name2, :column => :name
  filter :name3, :column => :name, :label => 'Three'
  filter :localname, :column => :name, :facet => true 

  filter :surname, :label => 'Surname'
  filter :profession

  filter :birthday, :range => true
  filter :birthday, :from => :between, :to => :and, :range => true

  filter :sex, :facet => true

  filter :teen_with_facet, :label => 'Teen', :facet => true do |scope|
    scope.where :birthday => (today - 19.years...today - 10.years)
  end 

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
    scope.where [ 'birthday <= ?', today - 29.years ] 
  end 

  filter :adult do |scope|
    scope.where [ 'birthday <= ?', today - 18.years ] 
  end 

  filter :age, :select => [:child, :teen, :twen, :other], :facet => true

  filter :male_scope, :scope => true
  filter :female_scope, :scope => :female_scope

  filter :sex_scope, :select => [:male_scope, :female_scope]
  filter :mixed_select, :select => [:female_scope, :teen]

  filter :any_name, :columns => [:name, :surname]
  filter :name_ignore,            :columns => :name, :ignore_case => true
  filter :name_inexact,           :columns => :name, :exact => false
  filter :name_inexact_ignore,    :columns => :name, :exact => false, :ignore_case => true
  filter :name_inexact_no_ignore, :columns => :name, :exact => false, :ignore_case => false

  search :search_name, :column => :name

  column :name, :order => true

  column :full_name, :order => 'name, surname', :order_desc => 'name DESC, surname DESC' do 
    "#{name} #{surname}"
  end

  column :profession, :header => 'Job Title', :order => true
end
