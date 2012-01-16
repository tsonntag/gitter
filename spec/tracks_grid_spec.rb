require 'spec_helper'

include Persons

describe TracksGrid do

  it 'should handle a scope' do
    class Foo < TracksGrid::Grid
      scope do 
        'bla'
      end
    end

    Foo.scope.call.should == 'bla'
  end
  
  it 'should complain for unset scope' do
    class Bar < TracksGrid::Grid
    end

    expect {
      Bar.scope
    }.to raise_error(
      TracksGrid::ConfigurationError, /undefined/
    )
  end

  it 'should handle filters' do
    class Foo2 < TracksGrid::Grid
      filter :foo
      filter :bar
    end

    Foo2.filter_specs.count.should == 2
    Foo2.filter_specs[:foo].should_not == nil
  end

  it 'should handle columns ' do
    class Foo4 < TracksGrid::Grid
      column :foo
      column :bar
    end
    Foo4.column_specs.count.should == 2
    Foo4.column_specs[:foo].should_not == nil
  end

end
