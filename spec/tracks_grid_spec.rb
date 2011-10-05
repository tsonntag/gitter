require 'spec_helper'

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
    check_include Lisa,           :age => :other 
  end

end
