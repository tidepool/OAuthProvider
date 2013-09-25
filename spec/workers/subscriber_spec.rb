require 'spec_helper'

describe Subscriber do

  let(:user1) { create(:user) }
  let(:fitbit) { create(:fitbit, user: user1)}

  it 'subscribes to fitbit' do 
    user1
    fitbit
    Fitgem::Client.any_instance.stub(:create_subscription).and_return([200, {}])

    subscriber = Subscriber.new
    subscriber.perform(fitbit.id)

    conn = Authentication.find(fitbit.id)
    conn.subscription_info.should == 'subscribed'
  end

  it 'handles an exception well' do 
    user1
    fitbit
    Fitgem::Client.any_instance.stub(:create_subscription) do |opts|
      raise Exception.new
    end

    subscriber = Subscriber.new
    subscriber.perform(fitbit.id)

    conn = Authentication.find(fitbit.id)
    conn.subscription_info.should == 'failed'

  end
end