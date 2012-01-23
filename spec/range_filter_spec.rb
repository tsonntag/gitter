require 'spec_helper'

include Persons

describe Gitter do

  context 'range filter' do
    it 'should complain for given block' do
      expect {
        class RangeFilterErr < Gitter::Grid
          filter :name, :range => true do
            # something
          end
        end
      }.to raise_error(
        Gitter::ConfigurationError, /no block allowed/
      )
    end
  end

  context 'filter with range' do 
    check_include Joe, Dick,     :birthday => (Date.new(1995,1,1)...Date.new(1997,1,1))
  end

  context 'filter with from ...to range' do 
    check_include Joe, Dick,    :from_birthday => Date.new(1995,1,1), :to_birthday => Date.new(1997,1,1) 
  end

  context 'filter with range and given :from, :to' do 
    check_include Joe, Dick,    :between => Date.new(1995,1,1), :and => Date.new(1997,1,1) 
  end
end
