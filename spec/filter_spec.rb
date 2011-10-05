require 'spec_helper'

describe TracksGrid do

  context 'range filter' do
    it 'should complain for given block' do
      expect {
        class RangeFilterErr
          include TracksGrid
          filter :name, :range => true do 
            # something
          end
        end
      }.to raise_error(
        TracksGrid::ConfigurationError, /no block allowed/
      )
    end
  end

  context 'select filter' do
    it 'should complain for invalid referenced filter' do
      expect {
        class SelectFilterErr
          include TracksGrid
          filter :name, :select => :foo 
        end
      }.to raise_error(
        TracksGrid::ConfigurationError, /no filter/
      )
    end
  end

end

describe TracksGrid::AbstractFilter do
  it 'should have a name and a default label' do
    f = TracksGrid::AbstractFilter.new :foo
    f.name.should == :foo
    f.label.should == 'Foo'
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

