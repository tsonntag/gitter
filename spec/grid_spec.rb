require 'spec_helper'

include Persons
include Gitter

describe Grid do

  it 'should have a name' do
    PersonGrid.new.name.should == 'person_grid'   
  end

  it 'should handle a scope' do
    class Foo < Grid
      scope do 
        'bla'
      end
    end

    Foo.new.scope.should == 'bla'
  end

  it 'should handle scope with helpers' do
    class Foo < Grid
      scope do 
        h.foo
      end
    end

    vc = Struct.new(:foo).new('bar')

    g = Foo.new(:view_context => vc)
    g.scope.should == 'bar'

  end
  
  it 'should have a default driver' do
    class Foo < Grid
      scope do
	'bla'
      end
    end

    Foo.driver_class.should == ActiveRecordDriver
    Foo.new.scope.should == 'bla'
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
    Foo.new.scope.should == 'bla'
  end
  
  it 'should complain for unset scope' do
    class Bar < Grid
    end

    expect {
      Bar.scope
    }.to raise_error(
      ConfigurationError
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
