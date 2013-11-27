require 'spec_helper'

describe 'Comments API' do 
  include AppConnections
  include ActivityStreamHelpers

  before :all do
    find_or_create_app
    @endpoint = '/api/v1'
  end

  let(:user1) { create(:friend_user, name: 'John Doe') }
  let(:make_friends) { create(:make_friends_activity, user: user1)}
  let(:comment) { create(:comment, user: user1, activity_record: make_friends) }
  let(:comments) { create_list(:comment, 15, user: user1, activity_record: make_friends) }

  it 'shows comments for a given activity' do
    comments

    token = get_conn(user1)
    response = token.get("#{@endpoint}/feeds/#{make_friends.id}/comments.json?offset=0&limit=5")
    result = JSON.parse(response.body, symbolize_names: true)
    comments = result[:data]
    comments.length.should == 5

    comments[0][:text].should_not be_nil
    comments[0][:user_name].should_not be_nil
    comments[0][:user_image].should_not be_nil
    status = result[:status]
    status.should == {
           :offset => 0,
            :limit => 5,
      :next_offset => 5,
       :next_limit => 5,
            :total => 15
    }
  end

  it 'creates a new comment for a given activity' do 
    token = get_conn(user1)

    params = { text: "Hello this is a comment" }
    response = token.post("#{@endpoint}/feeds/#{make_friends.id}/comments.json", {body: { comment: params }})
    result = JSON.parse(response.body, symbolize_names: true)
    comment = result[:data]
    comment[:text].should == params[:text]

    created_comment = Comment.find(comment[:id])
    created_comment.id.should == comment[:id] 
  end

  it 'updates the text of a comment' do 
    comment
    token = get_conn(user1)
    params = { text: "Hello this is a new comment" }
    response = token.put("#{@endpoint}/comments/#{comment.id}.json", {body: { comment: params }})
    result = JSON.parse(response.body, symbolize_names: true)
    comment = result[:data]
    comment[:text].should == params[:text]
  end

  it 'deletes a comment' do 
    comment
    token = get_conn(user1)
    response = token.delete("#{@endpoint}/comments/#{comment.id}.json")
    result = JSON.parse(response.body, symbolize_names: true)
    response.status.should == 200

    deleted_comment = Comment.where(id: comment.id).first
    deleted_comment.should be_nil
  end

end