require 'spec_helper'

describe Api::V1::UsersController do
  before :all do 
    user_email = 'user@example.com'
    user2_email = 'user2@example.com'
    admin_email = 'admin@example.com'
    @user = User.where('email = ?', user_email).first
    @user2 = User.where('email = ?', user2_email).first
    @admin = User.where('email = ?', admin_email).first
    @definition = Definition.first
  end

  it 'should be able to get any users info, if the caller is an admin' do

  end

  it 'should be able to get only users own info if the caller is not admin' do

  end

  it 'should be able to get the info using id=- as the parameter' do 

  end

  it 'should be able to create a user with username and password' do
  end
  
end
