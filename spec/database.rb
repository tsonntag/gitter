ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

ActiveRecord::Schema.define do
  create_table :people do |t|
    t.string :name, :surname, :sex, :profession
    t.date :birthday
  end
end

WillPaginate.enable
