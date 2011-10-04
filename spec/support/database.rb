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
  Max  = Person.create :name => 'Max',    :surname => 'Kid',   :birthday => Time.utc(2003,1,1), :sex => 'm', :profession => 'student'
  Tina = Person.create :name => 'Tina',   :surname => 'Child', :birthday => Time.utc(2002,1,1), :sex => 'f', :profession => 'student'
  Joe  = Person.create :name => 'Joe',    :surname => 'Teen',  :birthday => Time.utc(1995,1,1), :sex => 'm', :profession => 'student'
  Dick = Person.create :name => 'Dick',   :surname => 'Teeny', :birthday => Time.utc(1996,1,1), :sex => 'm', :profession => 'student'
  Dana = Person.create :name => 'Dana',   :surname => 'Twen',  :birthday => Time.utc(1985,1,1), :sex => 'f', :profession => 'teacher' 
  John = Person.create :name => 'John',   :surname => 'Twen',  :birthday => Time.utc(1985,2,1), :sex => 'm', :profession => 'teacher' 
  Lisa = Person.create :name => 'Lisa',   :surname => 'Adult', :birthday => Time.utc(1980,2,1), :sex => 'f', :profession => 'dentist' 
end
