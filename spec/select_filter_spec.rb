require 'spec_helper'

include Persons

describe TracksGrid do

 context 'select filter' do
    it 'should complain for invalid referenced filter' do
      expect {
        class SelectFilterErr < TracksGrid::Grid
          filter :name, :select => :foo
        end
      }.to raise_error(
        TracksGrid::ConfigurationError, /no filter/
      )
    end
  end

  context 'filter with select' do
    check_include Joe, Dick,      :age => :teen
    check_include Dana, John,     :age => :twen 
    check_include Lisa,           :age => :other 
  end

end
