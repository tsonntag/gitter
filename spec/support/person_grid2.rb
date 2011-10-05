class PersonGrid2
  include TracksGrid

  scope do
    Person.scoped
  end

  column :name do |model|
    #helpers.link_to model.name, "/person/#{model.id}"
    helpers.content_tag 'foo'
  end

end
