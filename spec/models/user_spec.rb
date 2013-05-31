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
  end

  it 'creates a user from auth_hash' do
    user = User.create_or_find(@facebook_hash)

    expect(user.email).to eq("user1@gmail.com")
    expect(user.name).to eq("John Doe")
    expect(user.image).to eq("http://graph.facebook.com/1222/picture?type=square")
    expect(user.gender).to eq("male")
    expect(user.timezone).to eq(-7)

    expect(user.authentications).not_to be_nil
    expect(user.authentications[0].email).to eq(user.email)    
  end

  it 'attaches the authentication to an existing user with user_id' do
    user = User.create_or_find(@facebook_hash, user1.id)

    expect(user.email).to eq(user1.email)
    expect(user.authentications[0].email).to eq(@facebook_hash.info.email)
    expect(user.id).to eq(user1.id)
  end

  it 'attaches the authentication to a guest and guest becomes registered' do
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
  end

  it 'finds no user if the user_id does not exist' do
    user = User.create_or_find(@facebook_hash, 12345)
    expect(user).to be_nil
  end

  it 'creates a guest user from attributes' do 

  end

end
