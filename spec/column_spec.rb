require 'spec_helper'

describe TracksGrid::Column do
  it 'should have name and header' do
    name_col = PersonGrid.column_descs[:name]
    name_col.name.should == :name
    name_col.header.should == 'Name'

    full_name_col = PersonGrid.column_descs[:full_name]
    full_name_col.name.should == :full_name
    full_name_col.header.should == 'Full name'
  end

  it 'should have headers' do
    g = PersonGrid.new
    g.headers.size.should == 3
    g.headers.should == [ 'Name', 'Full name', 'Job Title' ]
  end

  it 'should have rows' do
    g = PersonGrid.new :order => :name
    g.rows.size.should == 7
    g.rows.should == [
       ["Dana", "Dana Twen", "teacher"],
       ["Dick", "Dick Teeny", "student"],
       ["Joe", "Joe Teen", "student"],
       ["John", "John Twen", "teacher"],
       ["Lisa", "Lisa Adult", "dentist"],
       ["Max", "Max Kid", "student"],
       ["Tina", "Tina Child", "student"]
    ]
  end

  it 'should order columns' do
    g = PersonGrid.new :order => :profession
    g.rows.size.should == 7
    g.rows.map{|r|r.last}.should == [
       "dentist",
       "student",
       "student",
       "student",
       "student",
       "teacher",
       "teacher"
    ]
  end

  it 'should order columns descending' do
    g = PersonGrid.new :order => :profession, :desc => true
    g.rows.size.should == 7
    g.rows.map{|r|r.last}.should == [
       "teacher",
       "teacher",
       "student",
       "student",
       "student",
       "student",
       "dentist"
    ]
  end

  it 'should order complex columns' do
    g = PersonGrid.new :order => :full_name
    g.rows.size.should == 7
    g.rows.should == [
       ["Dana", "Dana Twen",  "teacher"],
       ["Dick", "Dick Teeny", "student"],
       ["Joe",  "Joe Teen",   "student"],
       ["John", "John Twen",  "teacher"],
       ["Lisa", "Lisa Adult", "dentist"],
       ["Max",  "Max Kid",    "student"],
       ["Tina", "Tina Child", "student"]
    ]
  end

  it 'should order complex columns descending' do
    g = PersonGrid.new :order => :full_name, :desc => true
    g.rows.size.should == 7
    g.rows.should == [
       ["Tina", "Tina Child", "student"],
       ["Max",  "Max Kid",    "student"],
       ["Lisa", "Lisa Adult", "dentist"],
       ["John", "John Twen",  "teacher"],
       ["Joe",  "Joe Teen",   "student"],
       ["Dick", "Dick Teeny", "student"],
       ["Dana", "Dana Twen",  "teacher"]
    ]
  end

  it 'should raise error for unknown order column' do
    expect { 
      PersonGrid.new :order => :bla 
    }.to raise_error( 
      ArgumentError, /order/ 
    )
  end
end
