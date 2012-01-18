require 'spec_helper'

include Persons
include TracksGrid

describe Grid do

  it 'should handle a scope' do
    class Foo < Grid
      scope do 
        'bla'
      end
    end

    Foo.scope.should == 'bla'
  end
  
  it 'should have a default driver' do
    class Foo < Grid
      scope do
	'bla'
      end
    end

    Foo.driver_class.should == ActiveRecordDriver
    Foo.driver.scope.should == 'bla'
  end
  
  it 'should handle given driver' do
    class MyDriver < AbstractDriver
    end

    class Foo < Grid
      driver_class MyDriver
      scope do
	'bla'
      end
    end

    Foo.driver_class.should == MyDriver
    Foo.driver.scope.should == 'bla'
  end
  
  it 'should complain for unset scope' do
    class Bar < Grid
    end

    expect {
      Bar.scope
    }.to raise_error(
      ConfigurationError, /undefined/
    )
  end

  it 'should handle filters' do
    class Foo2 < Grid
      filter :foo
      filter :bar
    end

    Foo2.filter_specs.count.should == 2
    Foo2.filter_specs[:foo].should_not == nil
  end

  it 'should handle columns ' do
    class Foo4 < Grid
      column :foo
      column :bar
    end
    Foo4.column_specs.count.should == 2
    Foo4.column_specs[:foo].should_not == nil
  end

end
