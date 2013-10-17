require 'spec_helper'

describe DestroyAuthentication do

  let(:user1) { create(:user) }
  let(:fitbit) { create(:fitbit, user: user1)}

  it 'deletes user authentication' do
    user1
    fitbit
    Fitgem::Client.any_instance.stub(:remove_subscription).and_return([204, {}])
    DestroyAuthentication.new.perform(user1.id, 'fitbit')

    conn = Authentication.where(id: fitbit.id).first    
    conn.should be_nil
  end

  it 'does not delete the user authentication if call to fitbit fails' do
    user1
    fitbit
    Fitgem::Client.any_instance.stub(:remove_subscription).and_return([404, {}])
    DestroyAuthentication.new.perform(user1.id, 'fitbit')

    conn = Authentication.where(id: fitbit.id).first    
    conn.should_not be_nil
  end
end