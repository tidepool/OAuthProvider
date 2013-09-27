require 'spec_helper'

describe FitbitRegistration do
  before :each do
    @fitbit_hash = Hashie::Mash.new(
      {
           "provider" => "fitbit",
                "uid" => "22NNBC",
               "info" => {
             "full_name" => "",
          "display_name" => "",
              "nickname" => "",
                "gender" => "MALE",
              "about_me" => nil,
                  "city" => nil,
                 "state" => nil,
               "country" => nil,
                   "dob" => "Wed, 20 Aug 1969",
          "member_since" => "Wed, 02 Nov 2011",
                "locale" => "en_US",
              "timezone" => "America/Los_Angeles"
        },
        "credentials" => {
           "token" => "fffddfdf",
          "secret" => "ffdfefffeeef"
        },
              "extra" => {
         # "access_token" => #<OAuth::AccessToken:0x007fc63cc2d788 @token="4b8f3d3eae93411192c491939c07808e", @secret="ff0127dd2c2c368be2444ef14c4ebe66", @consumer=#<OAuth::Consumer:0x007fc63c91e1a0 @key="4c4660694a7844d081bfaf93ef0d2330", @secret="b31bf5b8dcc748ea900b9c487d86973d", @options={:signature_method=>"HMAC-SHA1", :request_token_path=>"/oauth/request_token", :authorize_path=>"/oauth/authorize", :access_token_path=>"/oauth/access_token", :proxy=>nil, :scheme=>:header, :http_method=>:post, :oauth_version=>"1.0", :site=>"http://api.fitbit.com"}, @http=#<Net::HTTP api.fitbit.com:80 open=false>, @http_method=:post, @uri=#<URI::HTTP:0x007fc63cc2cd38 URL:http://api.fitbit.com>>, @params={:oauth_token=>"4b8f3d3eae93411192c491939c07808e", "oauth_token"=>"4b8f3d3eae93411192c491939c07808e", :oauth_token_secret=>"ff0127dd2c2c368be2444ef14c4ebe66", "oauth_token_secret"=>"ff0127dd2c2c368be2444ef14c4ebe66", :encoded_user_id=>"22NNBC", "encoded_user_id"=>"22NNBC"}, @response=#<Net::HTTPOK 200 OK readbody=true>>,
              "raw_info" => {
            "user" => {
                           "avatar" => "http://cache.fitbit.com/38AC23FC-7AC2-BA16-A1BD-39885AB91048_profile_100_square.jpg",
                      "dateOfBirth" => "1969-08-20",
                      "displayName" => "",
                     "distanceUnit" => "en_US",
                        "encodedId" => "22NNBC",
                      "foodsLocale" => "en_US",
                         "fullName" => "",
                           "gender" => "MALE",
                      "glucoseUnit" => "en_US",
                           "height" => 170.20000000000002,
                       "heightUnit" => "en_US",
                           "locale" => "en_US",
                      "memberSince" => "2011-11-02",
                         "nickname" => "",
              "offsetFromUTCMillis" => -25200000,
              "strideLengthRunning" => 0,
              "strideLengthWalking" => 0,
                         "timezone" => "America/Los_Angeles",
                        "waterUnit" => "en_US",
                           "weight" => 90.72,
                       "weightUnit" => "en_US"
            }
          }
        }
      })   
  end 

  let(:user1) { create(:user) }
  let(:authentication) { create(:authentication, user: user1) }

  it 'populates fields from Fitbit' do 
    user1
    authentication
    fitbit_reg = FitbitRegistration.new(user1, authentication)
    fitbit_reg.populate(@fitbit_hash)

    user1.date_of_birth.should == Date.new(1969, 8, 20)
    user1.image.should == "http://cache.fitbit.com/38AC23FC-7AC2-BA16-A1BD-39885AB91048_profile_100_square.jpg"
    user1.gender.should == "male"
  end

  it 'subscribes to fitbit for notifications' do 
    user1
    authentication
    Fitgem::Client.any_instance.stub(:create_subscription).and_return([200, {}])

    fitbit_reg = FitbitRegistration.new(user1, authentication)
    fitbit_reg.create_subscription

    authentication.subscription_info.should == 'subscribed'
  end

  it 'fails to subscribe to fitbit for notifications if fitbit returns 409' do 
    user1
    authentication
    Fitgem::Client.any_instance.stub(:create_subscription).and_return([409, {}])

    fitbit_reg = FitbitRegistration.new(user1, authentication)
    fitbit_reg.create_subscription

    authentication.subscription_info.should == 'failed'
  end

end