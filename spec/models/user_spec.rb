require 'spec_helper'
require 'hashie'

describe User do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }  
  let(:guest) { create(:guest) }
  let(:auth2) { create(:authentication, user: user2) }
  let(:auth3) { create(:authentication, { user: user3, uid: "5555", provider: "facebook"}) }

  before :all do
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

  it 'creates a user from auth_hash when no prior guest user existed.' do
    user = User.create_or_find(@facebook_hash)

    expect(user.email).to eq("user1@gmail.com")
    expect(user.name).to eq("John Doe")
    expect(user.image).to eq("http://graph.facebook.com/1222/picture?type=square")
    expect(user.gender).to eq("male")
    expect(user.timezone).to eq(-7)
    expect(user.guest).to eq(false)

    expect(user.authentications).not_to be_nil
    expect(user.authentications[0].email).to eq(user.email)    
  end

  it 'attaches the authentication to an existing user with user_id' do
    user = User.create_or_find(@facebook_hash, user1.id)

    expect(user.email).to eq(user1.email)
    expect(user.authentications[0].email).to eq(@facebook_hash.info.email)
    expect(user.id).to eq(user1.id)
    expect(user.guest).to eq(false)
  end

  it 'attaches the new authentication to a guest and guest becomes registered' do
    expect(guest.guest).to eq(true)
    user = User.create_or_find(@facebook_hash, guest.id)

    expect(user.email).to eq(@facebook_hash.info.email)
    expect(user.guest).to eq(false)
    expect(user.id).to eq(guest.id)
  end

  it 'finds an existing authentication and returns the user associated with' do
    @test_hash = Hashie::Mash.new(
          {
            "provider" => "facebook",
                 "uid" => "5555",
                "info" => { "email" => "test@example.com" }
          })

    expect(auth3.user).to eq(user3)
    expect(user3.authentications[0].uid).to eq("5555")
    user = User.create_or_find(@test_hash)

    expect(user.id).to eq(user3.id)
    expect(user.guest).to eq(false)
  end

  it 'returns the existing user if there is an existing authentication and ignores the guest' do 
    # This will leave a potential guest user dangling, but it is ok.
    expect(guest.guest).to eq(true)
    @test_hash = Hashie::Mash.new(
          {
            "provider" => "facebook",
                 "uid" => "5555",
                "info" => { "email" => "test@example.com" }
          })      
    expect(auth3.user).to eq(user3)
    expect(user3.authentications[0].uid).to eq("5555")

    user = User.create_or_find(@test_hash, guest.id)
    expect(user.id).to eq(user3.id)
    expect(user.guest).to eq(false)
  end

  it 'adds a new authentication to an existing user with external authentication' do 
    auth3 # Has Facebook authentication
    user = User.create_or_find(@fitbit_hash, user3.id)
    expect(user.authentications.length).to eq(2)
    expect(user.authentications[0].provider).to eq('fitbit')
    expect(user.password_digest).to eq(user3.password_digest)
    expect(user.date_of_birth.to_s).to eq("1969-08-20")
  end

  it 'adds a new authentication to an existing user with email/password authentication' do 
    user = User.create_or_find(@fitbit_hash, user1.id)
    expect(user.authentications.length).to eq(1)
    expect(user.password_digest).to eq(user1.password_digest)
    expect(user.date_of_birth.to_s).to eq("1969-08-20")
  end

  it 'adds a new authentication to a guest user' do 
    user = User.create_guest_or_registered({guest: true})
    expect(user.guest).to be_true
    expect(user.password_digest).to eq("Tidepool-Guest-User")

    updated_user = User.create_or_find(@facebook_hash, user.id)
    expect(updated_user.password_digest).to eq("Tidepool-Guest-User")
    expect(updated_user.authentications.length).to eq(1)
  end

  it 'switches the authentication to a new user if the authentication existed and belonged to another user' do 
    @test_hash = Hashie::Mash.new(
          {
            "provider" => "facebook",
                 "uid" => "5555",
                "info" => { "email" => "test@example.com" }
          })      
    auth3 # Belongs to user3
    user = User.create_or_find(@test_hash, user1.id) # Try to assign to user1
    expect(user.authentications.length).to eq(1)

    updated_auth = Authentication.find(auth3.id)
    expect(updated_auth.user_id).to eq(user1.id)   
  end

  it 'finds no user if the user_id does not exist' do
    user = User.create_or_find(@facebook_hash, 12345)
    expect(user).to be_nil
  end

  it 'creates a guest user from attributes' do 
    user = User.create_guest_or_registered({guest: true})
    expect(user.guest).to be_true
    expect(user.password_digest).to eq("Tidepool-Guest-User")
  end

  it 'creates a registered user from attributes' do
    params = {
      email: 'foo@foo.com',
      password: '12345678',
      password_confirmation: '12345678'
    }
    user = User.create_guest_or_registered(params)
    expect(user.guest).to be_false
    expect(user.email).to eq('foo@foo.com')
  end

  it 'denies new user creation if password confirmation is not correct' do 
    params = {
      email: 'foo@foo.com',
      password: '12345678',
      password_confirmation: '12345378'
    }
    expect{ User.create_guest_or_registered!(params)}.to raise_error(ActiveRecord::RecordInvalid)

  end
end
