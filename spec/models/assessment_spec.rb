require 'spec_helper'

describe Assessment do
  before :all do
    user_email = 'user@example.com'
    user2_email = 'user2@example.com'
    admin_email = 'admin@example.com'
    @user = User.where('email = ?', user_email).first
    @user2 = User.where('email = ?', user2_email).first
    @admin = User.where('email = ?', admin_email).first
    @definition = Definition.first
  end
  
  it 'should not allow me to create if no definition is specified' do
    lambda {Assessment.create_by_caller(nil, nil, nil)}.should raise_error(ArgumentError)
  end

  it 'should create an assessment for anonymous user' do
    # The caller is not identified and the user is not specified
    # Just create an anonymous assessment
    # (This supports the first time user case, so they don't need to create a user account
    # before taking assessment)
    assessment = Assessment.create_by_caller(@definition, nil, nil)
    assessment.should_not be_nil
    assessment.user_id.should == 0
  end

  it 'should create an assessment for a user if the caller is admin' do
    assessment = Assessment.create_by_caller(@definition, @admin, @user)
    assessment.should_not be_nil
    assessment.user_id.should == @user.id
  end

  it 'should create an assessment if the caller is the user' do
    assessment = Assessment.create_by_caller(@definition, @user, @user)
    assessment.should_not be_nil
    assessment.user_id.should == @user.id
  end

  it 'should not be able to create an assessment for a user if the caller is nil' do
    lambda {Assessment.create_by_caller(@definition, nil, @user2)}.should raise_error(Assessment::UnauthorizedError)
  end

  it 'should not be able to create an assessment for a user if the caller is not admin or the user themselves' do
    lambda {Assessment.create_by_caller(@definition, @user, @user2)}.should raise_error(Assessment::UnauthorizedError)
  end  

  it 'should be able to add to user if caller is user' do
    assessment = Assessment.create_by_caller(@definition, nil, nil)
    assessment.add_to_user(@user, @user) 
    assessment.user_id.should == @user.id   
  end

  it 'should be able to add to user if caller is admin' do
    assessment = Assessment.create_by_caller(@definition, nil, nil)
    assessment.add_to_user(@admin, @user)    
    assessment.user_id.should == @user.id
  end

  it 'should not be able to add to user if caller is nil' do
    lambda {Assessment.create_by_caller(@definition, nil, @user)}.should raise_error(Assessment::UnauthorizedError)
  end

  it 'should not be able to create an assessment for a user if the caller is not admin or the user themselves' do
    lambda {Assessment.create_by_caller(@definition, @user, @user2)}.should raise_error(Assessment::UnauthorizedError)
  end  

  it 'should be able to get an assessment by id' do
    assessment = Assessment.create_by_caller(@definition, @user, @user)

    found_assessment = Assessment.find_by_caller_and_user(assessment.id, @user, @user)
    found_assessment.id.should == assessment.id
  end

  it 'should be able to get the latest assessment' do 
    assessment1 = Assessment.create_by_caller(@definition, @user, @user)
    sleep(1)
    assessment2 = Assessment.create_by_caller(@definition, @user, @user)
    sleep(1)
    assessment3 = Assessment.create_by_caller(@definition, @user, @user)

    found_assessment = Assessment.find_latest_by_caller_and_user(@user, @user)
    found_assessment.id.should == assessment3.id
  end

end
