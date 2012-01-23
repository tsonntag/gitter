require 'spec_helper'

include Gitter

describe Grid do

  it 'should handle one breadcrumb' do
    g = PersonGrid.new :name => 'bla'
    g.breadcrumbs.should == { 'Name' => 'bla' }
  end

  it 'should handle breadcrumb with label' do
    g = PersonGrid.new :name3 => 'bla'
    g.breadcrumbs.should == { 'Three' => 'bla' }
  end

  it 'should handle many breadcrumbs' do
    g = PersonGrid.new :name => 'Mike', :surname => 'Miller'
    g.breadcrumbs.should == { 'Name' => 'Mike', 'Surname' => 'Miller' }

    g = PersonGrid.new :surname => 'Miller', :name => 'Mike'
    g.breadcrumbs.should == { 'Surname' => 'Miller', 'Name' => 'Mike' }
  end
end
