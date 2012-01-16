class PersonGrid2 < TracksGrid::Grid

  scope do
    Person.scoped
  end

  column :name do 
    name 
  end

end
