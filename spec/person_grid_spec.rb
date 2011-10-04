require 'spec_helper'

def check_include(*args)
  params = args.extract_options!
  all = Set.new PersonGrid.new(params).all
  expected = Set.new [args].flatten
  specify { all.should == expected }
end

def grid_set( params )
  Set.new PersonGrid.new(params).all
end

def set( args )
  expected = Set.new [args].flatten
end

include Persons

describe TracksGrid do

  it 'should handle a scope' do
    class Foo
      include TracksGrid

      scope do 
        'bla'
      end
    end

    Foo.scope.should == 'bla'
  end

  it 'should handle filters' do
    class Foo
      include TracksGrid
      filter :foo
      filter :bar
    end

    Foo.filters.count.should == 2
    Foo.filters[:foo].should_not == nil
  end

  it 'should handle facets ' do
    class Foo
      include TracksGrid
      filter :foo, :facet => true
      filter :bar
    end
    Foo.facets.count.should == 1
    Foo.facets[:foo].should_not == nil
  end

  context 'column filter' do 
    check_include Max,          :name => 'Max'
    check_include Lisa,         :surname => 'Adult' 
  end

  context 'block filter' do 
    check_include  Joe, Dick,       :teen => true 
    check_include  Dana, John,      :twen => true 
  end

  context 'filter with range' do 
    check_include Joe, Dick,     :birthday => (Time.utc(1995,1,1)...Time.utc(1997,1,1))
  end

  context 'filter with from ...to range' do 
    check_include Joe, Dick,    :from_birthday => Time.utc(1995,1,1), :to_birthday => Time.utc(1997,1,1) 
  end

  context 'filter with select' do
    check_include Joe, Dick,      :age => :teen
    check_include Dana, John,     :age => :twen 
  end

  context 'search with many columns' do
    check_include Max, Tina, Dick, Lisa,         :search => 'i' 
    check_include Joe, Dick,                     :search => 'teen' 
  end

  context 'default search (not exact, ignore case)' do
    check_include Tina, Lisa, Dick,              :search_name => 'i' 
    check_include Tina, Lisa, Dick,              :search_name => 'I' 
    check_include Joe, John,                     :search_name => 'o' 
    check_include Joe, John,                     :search_name => 'O' 
  end

  context 'search with ignore case' do
    check_include Joe, John,                     :search_name_ignore => 'O' 
    check_include Joe, John,                     :search_name_ignore => 'o' 
    check_include Joe,                           :search_name_ignore => 'joe' 
    check_include Joe,                           :search_name_ignore => 'Joe' 
  end

  context 'search with case' do
    # sqlite does allow case sensitive LIKE
    #check_include                                :search_name_no_ignore => 'O' 
    check_include Joe, John,                     :search_name_no_ignore => 'o' 
    #check_include                                :search_name_no_ignore => 'joe' 
    check_include Joe,                           :search_name_no_ignore => 'Joe' 
  end

  context 'exact search (ignore case)' do
    check_include                                :search_name_exact => 'O' 
    check_include Joe,                           :search_name_exact => 'joe' 
    check_include Joe,                           :search_name_exact => 'Joe' 
  end

  context 'exact search with ignore case' do
    check_include                                :search_name_exact_ignore => 'O' 
    check_include Joe,                           :search_name_exact_ignore => 'joe' 
    check_include Joe,                           :search_name_exact_ignore => 'Joe' 
  end

  context 'exact search with case' do
    check_include                                :search_name_exact_no_ignore => 'O' 
    check_include                                :search_name_exact_no_ignore => 'joe' 
    check_include Joe,                           :search_name_exact_no_ignore => 'Joe' 
  end

end

describe TracksGrid::AbstractFilter do
  it 'should have a name and a default label' do
    f = TracksGrid::AbstractFilter.new :foo
    f.name.should == :foo
    f.label.should == 'foo'
  end

  it 'should accept a label' do
    f = TracksGrid::AbstractFilter.new :foo, :label => 'bla'
    f.name.should == :foo
    f.label.should == 'bla'
  end
end

describe TracksGrid::ColumnFilter do
  it 'should have a default column' do
    f = TracksGrid::ColumnFilter.new :foo
    f.name.should == :foo
    f.column.should == :foo 
  end

  it 'should accept a column' do
    f = TracksGrid::ColumnFilter.new :foo, :column => :bar
    f.name.should == :foo
    f.column.should == :bar 
  end
end

