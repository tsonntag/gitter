require 'spec_helper'

def check_facet( facets, name, label, size )
  #puts "facets=#{facets.inspect}"
  f = facets.detect{|f|f.name == name}
  #puts "f=#{f.inspect}"
  #puts "values=#{f.values.inspect}"
  f.should_not == nil
  f.name.should == name 
  f.label.should == label 
  f.values.size.should == size
  f.values.each do |v|
    v.name.should == name
  end
  f
end

def check_facet_value( facet, value, count )
  v = facet.values.detect{|v|v.value == value}
  v.should_not == nil
  v.value.should == value 
  v.count.should == count 
  v.filter_params.should == { v.name => value }
end

describe TracksGrid do

  context 'facets' do
    it 'should manage facets' do
      PersonGrid.facets.count.should == 3
      PersonGrid.facets.size.should == 3
    end

    it 'should manage column facets' do
      facets = PersonGrid.new.facets

      f = check_facet facets, :sex, 'Sex', 2
      check_facet_value f, 'f', 3
      check_facet_value f, 'm', 4
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
