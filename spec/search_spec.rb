require 'spec_helper'

include Persons

describe TracksGrid do

  context 'search with many columns' do
    check_include Max, Tina, Dick, Lisa,         :search => 'i' 
    check_include Joe, Dick,                     :search => 'teen' 
  end

  context 'default search (not exact, ignore case)' do
    check_include Tina, Lisa, Dick,              :search_name => 'i' 
    check_include Tina, Lisa, Dick,              :search_name => 'I' 
    check_include Joe, John,                     :search_name => 'o' 
    check_include Joe, John,                     :search_name => 'O' 
  end

  context 'search with ignore case' do
    check_include Joe, John,                     :search_name_ignore => 'O' 
    check_include Joe, John,                     :search_name_ignore => 'o' 
    check_include Joe,                           :search_name_ignore => 'joe' 
    check_include Joe,                           :search_name_ignore => 'Joe' 
  end

  context 'search with case' do
    # sqlite does allow case sensitive LIKE
    #check_include                                :search_name_no_ignore => 'O' 
    check_include Joe, John,                     :search_name_no_ignore => 'o' 
    #check_include                                :search_name_no_ignore => 'joe' 
    check_include Joe,                           :search_name_no_ignore => 'Joe' 
  end

  context 'exact search (ignore case)' do
    check_include                                :search_name_exact => 'O' 
    check_include Joe,                           :search_name_exact => 'joe' 
    check_include Joe,                           :search_name_exact => 'Joe' 
  end

  context 'exact search with ignore case' do
    check_include                                :search_name_exact_ignore => 'O' 
    check_include Joe,                           :search_name_exact_ignore => 'joe' 
    check_include Joe,                           :search_name_exact_ignore => 'Joe' 
  end

  context 'exact search with case' do
    check_include                                :search_name_exact_no_ignore => 'O' 
    check_include                                :search_name_exact_no_ignore => 'joe' 
    check_include Joe,                           :search_name_exact_no_ignore => 'Joe' 
  end

end
