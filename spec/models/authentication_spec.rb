require 'spec_helper'

describe Authentication do
  it 'checks and resets credentials' do 
    auth_hash = Hashie::Mash.new({
      "provider" => "facebook",
      "uid" => "facebook user id",
      "info" => {
        "email" => "email",
        "name" => "name",
        "image" => "image_url"
      },
      "credentials" => {
        "token" => "facebook token",
        "secret" => "for Oauth 1.0 providers only",
        "refresh_at" => Time.zone.parse("2013-07-31T15:17:35.520-0700"),
        "permissions" => ["basic_info","publish_actions"],
        "expires_at" => "2013-09-28T19:44:46.520-0700",
        "expires" => true
      }
    })
    auth = Authentication.new
    auth.check_and_reset_credentials(auth_hash)
    auth.oauth_token.should == "facebook token"
    auth.oauth_secret.should == "for Oauth 1.0 providers only"
    auth.oauth_expires_at.should == Time.zone.parse("2013-09-28T19:44:46.520-0700")
    auth.oauth_refresh_at.should == Time.zone.at(Time.zone.parse("2013-07-31T15:17:35.520-0700"))
    auth.expires.should == true
    auth.permissions.should == ["basic_info","publish_actions"]

    auth.provider = auth_hash.provider
    auth.uid = auth_hash.uid

    status = auth.save
    status.should_not be_nil
  end

  it 'does not fail at checking resetting credentials if some info is missing' do 
    auth_hash = Hashie::Mash.new({
      "provider" => "facebook",
      "uid" => "facebook user id",
      "info" => {
        "email" => "email",
        "name" => "name",
        "image" => "image_url"
      },
      "credentials" => {
        "token" => "facebook token",
        "secret" => "for Oauth 1.0 providers only",
        "permissions" => ["basic_info","publish_actions"],
        "expires_at" => nil,
      }
    })
    auth = Authentication.new
    auth.check_and_reset_credentials(auth_hash)
    auth.oauth_token.should == "facebook token"
  end
end
