class UsersController < ApplicationController
  active_scaffold :user do |config|
    config.label = "Users"
    config.columns = [:login, :email, :first_name, :last_name, :last_log_time, :handset_number, :admin]
    #config.columns[:admin].label = "Admin?"
    #list.columns.exclude :password
    #list.sorting = {:username => 'ASC'}
    #columns[:phone].label = "Phone #"
    #columns[:phone].description = "(Format: ###-###-####)"
  end
end
