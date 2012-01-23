require 'spec_helper'

include Persons

describe Gitter do

  context 'column filter' do 
    check_include Max,          :name => 'Max'
    check_include Lisa,         :surname => 'Adult' 
    check_include John, Dana,   :surname => 'Twen' 
  end

  context 'column filter with :column' do 
    check_include Max,          :name2 => 'Max'
  end

  context 'column filter with instance ignore_case' do 
    check_include [],          :name => 'max'
    check_include [],          :name => 'max', :ignore_case => false
    check_include Max,         :name => 'max', :ignore_case => true
  end

  context 'column filter with instance inexact' do 
    check_include [],          :name => 'ax'
    check_include [],          :name => 'ax', :exact => true
    check_include Max,         :name => 'ax', :exact => false
  end

  context 'column filter with many columns' do 
    check_include Max,          :any_name => 'Max'
    check_include Max,          :any_name => 'Kid'
  end

  context 'column filter with many columns with ignore_case' do 
    check_include [],           :any_name => 'max'
    check_include [],           :any_name => 'ax', :exact => true
    check_include Max,          :any_name => 'ax', :exact => false
    check_include [],           :any_name => 'id'
    check_include [],           :any_name => 'id', :exact => true
    check_include Max,          :any_name => 'id', :exact => false
  end

  context 'column filter with many columns with inexact' do 
    check_include [],          :any_name => 'max'
    check_include [],          :any_name => 'max', :ignore_case => false
    check_include Max,         :any_name => 'max', :ignore_case => true
    check_include [],          :any_name => 'kid'
    check_include [],          :any_name => 'kid', :ignore_case => false
    check_include Max,         :any_name => 'kid', :ignore_case => true
  end

  context 'column filter with ignore_case' do 
    check_include Max,         :name_ignore => 'max'
    check_include Max,         :name_ignore => 'Max'

    check_include [],          :name_ignore => 'max', :ignore_case => false
    check_include Max,         :name_ignore => 'Max', :ignore_case => false

    check_include Max,         :name_ignore => 'max', :ignore_case => true
    check_include Max,         :name_ignore => 'Max', :ignore_case => true
  end

  context 'column filter with instance inexact' do 
    check_include Max,         :name_inexact => 'ax'
    check_include Max,         :name_inexact => 'Max'

    check_include [],          :name_inexact => 'ax',  :exact => true
    check_include Max,         :name_inexact => 'Max', :exact => true

    check_include Max,         :name_inexact => 'ax',  :exact => false
    check_include Max,         :name_inexact => 'Max', :exact => false
  end

  context 'search'  do 
    check_include Max,          :search_name => 'Max'
    check_include Max,          :search_name => 'max'
    check_include Max,          :search_name => 'ax'
    check_include [],           :search_name => 'Kid'
  end
end
