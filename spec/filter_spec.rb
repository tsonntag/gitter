require 'spec_helper'

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

