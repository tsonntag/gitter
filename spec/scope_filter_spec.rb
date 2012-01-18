require 'spec_helper'

include Persons

describe TracksGrid do

  context 'filter with one scope' do
    check_include Tina, Dana, Lisa,     :female_scope => true 
    check_include Max, Joe, Dick, John, :male_scope => true
  end

end
