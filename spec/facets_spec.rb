require 'spec_helper'

def check_facet( facets, name, label, size )
  f = facets.detect{|f|f.name == name}
  f.should_not == nil
  f.name.should == name 
  f.label.should == label 
  data = f.data(:include_zeros => true)
  data.size.should == size
  data.each do |v|
    v.name.should == name
  end
  f
end

def check_facet_value( facet, value, count )
  v = facet.data.detect{|v|v.value == value}
  v.should_not == nil
  v.value.should == value 
  v.count.should == count 
  v.params.should == { v.name => value }
end

describe Gitter do

  context 'facets' do
    it 'should manage facets' do
      PersonGrid.facets.count.should == 5
      PersonGrid.facets.size.should == 5
    end

    it 'should handle facets ' do
      class Bla < Gitter::Grid
        filter :foo, :facet => true
        filter :bar
      end
      Bla.facets.count.should == 1
      Bla.facets.should include(:foo)
    end

    it 'should manage column facets' do
      facets = PersonGrid.new.facets
      f = check_facet facets, :sex, 'Sex', 2
      check_facet_value f, 'f', 3
      check_facet_value f, 'm', 4
    end

    it 'should manage boolean column facets' do
      facets = PersonGrid.new.facets
      f = check_facet facets, :teen_with_facet, 'Teen', 2
      check_facet_value f, true,  2
    end

    it 'should manage select facets' do
      facets = PersonGrid.new.facets

      f = check_facet facets, :age, 'Age', 4
      check_facet_value f, :child, 2
      check_facet_value f, :teen,  2
      check_facet_value f, :twen,  2
      check_facet_value f, :other, 1
    end

    it 'should manage select facets with scope' do
      g = PersonGrid.new(:profession => 'student')
      facets = g.facets

      f = check_facet facets, :age, 'Age', 4
      check_facet_value f, :child, 2
      check_facet_value f, :teen,  2
      check_facet_value f, :twen,  0
      check_facet_value f, :other, 0
    end
  end
end
