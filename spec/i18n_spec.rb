require 'spec_helper'

include Persons

def __find__( clazz, what, name )
  g = clazz.new name => 'bla'
  f = g.send(what).detect{|w|w.name == name}
  f.name.should == name
  f
end

def check_local( en, de )
  I18n.locale = :en
  yield.should == en
  I18n.locale = :de
  yield.should == de
end

describe 'I18n' do
  it 'should translate filter labels' do
    check_local('en_name', 'de_name'){ __find__(PersonGrid, :filters, :localname).label }
  end

  it 'should translate facet labels' do
    check_local('en_label', 'de_label'){ __find__(PersonGrid, :facets, :localname).label }
  end

  class HeaderGrid < TracksGrid::Grid
    scope do Person.scoped end
    column :localname, :for => :name
  end
  
  it 'should translate column headers' do
    check_local('en_header', 'de_header'){ __find__(HeaderGrid, :columns, :localname).header }
  end

end
