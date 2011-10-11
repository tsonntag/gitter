ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

ActiveRecord::Schema.define do
  create_table :people do |t|
    t.string :name, :surname, :sex, :profession
    t.date :birthday
  end
end

class Person < ActiveRecord::Base
end

module Persons
  Max  = Person.create :name => 'Max',    :surname => 'Kid',   :birthday => Date.new(2003,1,1), :sex => 'm', :profession => 'student'
  Tina = Person.create :name => 'Tina',   :surname => 'Child', :birthday => Date.new(2002,1,1), :sex => 'f', :profession => 'student'
  Joe  = Person.create :name => 'Joe',    :surname => 'Teen',  :birthday => Date.new(1995,1,1), :sex => 'm', :profession => 'student'
  Dick = Person.create :name => 'Dick',   :surname => 'Teeny', :birthday => Date.new(1996,1,1), :sex => 'm', :profession => 'student'
  Dana = Person.create :name => 'Dana',   :surname => 'Twen',  :birthday => Date.new(1985,1,1), :sex => 'f', :profession => 'teacher' 
  John = Person.create :name => 'John',   :surname => 'Twen',  :birthday => Date.new(1985,2,1), :sex => 'm', :profession => 'teacher' 
  Lisa = Person.create :name => 'Lisa',   :surname => 'Adult', :birthday => Date.new(1980,2,1), :sex => 'f', :profession => 'dentist' 
end
