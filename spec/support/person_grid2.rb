class PersonGrid2
  include TracksGrid

  scope do
    Person.scoped
  end

  column :name do 
    model.name 
  end

end
