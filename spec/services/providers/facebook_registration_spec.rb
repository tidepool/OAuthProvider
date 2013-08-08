require 'spec_helper'

describe FacebookRegistration do
  before :each do
    @facebook_hash = Hashie::Mash.new(
     {
      "provider" => "facebook",
           "uid" => "1222",
          "info" => {
              "nickname" => "user1",
                 "email" => "user1@gmail.com",
                  "name" => "John Doe",
            "first_name" => "John",
             "last_name" => "Doe",
                 "image" => "http://graph.facebook.com/1222/picture?type=square",
                  "urls" => { "Facebook" => "http://www.facebook.com/kkaratal" },
              "verified" => true
                     },
    "credentials" => {
                 "token" => "1234",
            "expires_at" => 1371247683,
               "expires" => true
                     },
         "extra" => {
              "raw_info" => {
                         "id" => "1222",
                       "name" => "Kerem Karatal",
                 "first_name" => "Kerem",
                  "last_name" => "Karatal",
                       "link" => "http://www.facebook.com/kkaratal",
                   "username" => "kkaratal",
                     "gender" => "male",
                      "email" => "kkaratal@gmail.com",
                   "timezone" => -7,
                     "locale" => "en_US",
                   "verified" => true,
               "updated_time" => "2013-04-15T22:07:43+0000"
                             }
                       }
       }) 
  end

  let(:user1) { create(:user) }
  let(:authentication) { create(:authentication, user: user1) }


  it 'populates fields from Facebook' do 
    user1
    authentication
    prior_email = user1.email
    facebook_reg = FacebookRegistration.new(user1, authentication)
    facebook_reg.populate(@facebook_hash)
    user1.name.should == "John Doe"
    user1.email.should == prior_email
    user1.image.should == "http://graph.facebook.com/1222/picture?type=square"
    user1.gender.should == "male"
    user1.timezone.should == -7
  end
end