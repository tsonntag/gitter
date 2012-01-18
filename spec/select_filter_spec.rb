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
        TracksGrid::ConfigurationError
      )
    end
  end

  context 'filter with select' do
    check_include Joe, Dick,      :age => :teen
    check_include Dana, John,     :age => :twen 
    check_include Lisa,           :age => :other 
  end

  context 'filter with select for scopes' do
    check_include Tina, Dana, Lisa,     :sex_scope => :female_scope
    check_include Max, Joe, Dick, John, :sex_scope => :male_scope
  end

  context 'filter with select for scopes and filters' do
    check_include Tina, Dana, Lisa,  :mixed_select => :female_scope
    check_include Joe, Dick,         :mixed_select => :teen
  end
end
