require 'spec_helper'

include Persons

describe Gitter do

  context 'filter with scope' do
    check_include Tina, Dana, Lisa,     :female_scope => true 
    check_include Max, Joe, Dick, John, :male_scope => true
  end

end
