require 'spec_helper'

describe 'Devices API' do 
  include AppConnections

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:friend_user, name: 'John Doe') }
  let(:ios_devices) { create_list(:device, 2, os: "ios", user: user1) }
  let(:android_devices) { create_list(:device, 2, os: "android", user: user1) }

  it 'shows devices for a given user and os' do
    ios_devices
    android_devices

    token = get_conn(user1)
    response = token.get("#{@endpoint}/users/-/devices.json?os=ios")
    result = JSON.parse(response.body, symbolize_names: true)
    devices = result[:data]
    devices.length.should == 2
    devices[0][:name].should_not be_nil
    devices[0][:os].should == 'ios'
    devices[0][:os_version].should_not be_nil
    devices[0][:hardware].should_not be_nil
    devices[0][:token].should_not be_nil

  end

  it 'creates a new device with a new token' do 
    token = get_conn(user1)

    params = { token: "Token123", os: "ios" }
    response = token.post("#{@endpoint}/users/-/devices.json", {body: { device: params }})
    result = JSON.parse(response.body, symbolize_names: true)
    device = result[:data]
    device[:token].should == params[:token]
    device[:os].should == params[:os]

    created_device = Device.find(device[:id])
    created_device.id.should == device[:id] 
    created_device.user_id.should == user1.id
    created_device.token.should == params[:token]
    created_device.os.should == params[:os]

  end

  it 'updates the name of a device' do 
    ios_devices
    token = get_conn(user1)
    params = { name: "My new device name" }
    response = token.put("#{@endpoint}/users/-/devices/#{ios_devices[0].id}.json", {body: { device: params }})
    result = JSON.parse(response.body, symbolize_names: true)
    device = result[:data]
    device[:name].should == params[:name]

    updated_device = Device.find(ios_devices[0].id)
    updated_device.name.should == params[:name]
  end

  it 'deletes a device' do 
    ios_devices

    token = get_conn(user1)
    response = token.delete("#{@endpoint}/users/-/devices/#{ios_devices[0].id}.json")
    result = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200

    deleted_device = Device.where(id: ios_devices[0].id).first
    deleted_device.should be_nil
  end

end