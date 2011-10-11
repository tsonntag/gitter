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

    Foo.scope.call.should == 'bla'
  end
  
  it 'should complain for unset scope' do
    class Bar
      include TracksGrid
    end

    expect {
      Bar.scope
    }.to raise_error(
      TracksGrid::ConfigurationError, /undefined/
    )
  end

  it 'should handle filters' do
    class Foo2
      include TracksGrid
      filter :foo
      filter :bar
    end

    Foo2.filters.count.should == 2
    Foo2.filters[:foo].should_not == nil
  end

  it 'should handle facets ' do
    class Foo3
      include TracksGrid
      filter :foo, :facet => true
      filter :bar
    end
    Foo3.facets.count.should == 1
    Foo3.facets[:foo].should_not == nil
  end

  it 'should handle columns ' do
    class Foo4
      include TracksGrid
      column :foo
      column :bar
    end
    Foo4.columns.count.should == 2
    Foo4.columns[:foo].should_not == nil
  end

  context 'column filter' do 
    check_include Max,          :name => 'Max'
    check_include Lisa,         :surname => 'Adult' 
  end

  context 'block filter' do 
    check_include  Joe, Dick,       :teen => true 
    check_include  Dana, John,      :twen => true 
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
    check_include Joe, Dick,     :birthday => (Date.new(1995,1,1)...Date.new(1997,1,1))
  end

  context 'filter with from ...to range' do 
    check_include Joe, Dick,    :from_birthday => Date.new(1995,1,1), :to_birthday => Date.new(1997,1,1) 
  end

  context 'filter with select' do
    check_include Joe, Dick,      :age => :teen
    check_include Dana, John,     :age => :twen 
    check_include Lisa,           :age => :other 
  end

end
