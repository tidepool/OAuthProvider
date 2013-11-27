require 'spec_helper'

module Permissions
  describe AnonymousPermission do
    let(:other_user) { create(:user) }
    let(:others_game) { create(:game, user: other_user) }
    subject { Permissions.permission_for(nil, other_user) }

    it 'anonymous permissions for games' do
      expect(subject.allow?(:games, :create)).to be_false
      expect(subject.allow?(:games, :destroy)).to be_false
      expect(subject.allow?(:games, :update, others_game)).to be_false
      expect(subject.allow?(:games, :show, others_game)).to be_false
      expect(subject.allow?(:games, :index)).to be_false

      expect(subject.allow?(:games, :latest, others_game)).to be_false
    end

    it 'anonymous permissions for results' do
      expect(subject.allow?(:results, :show, others_game)).to be_false
      expect(subject.allow?(:results, :progress, others_game)).to be_false
    end

    it 'anonymous permissions for users' do 
      target_user = other_user

      expect(subject.allow?(:users, :show, target_user)).to be_false
      expect(subject.allow?(:users, :create)).to be_true
      expect(subject.allow?(:users, :update, target_user)).to be_false
      expect(subject.allow?(:users, :destroy, target_user)).to be_false
      expect(subject.allow?(:users, :personality, target_user)).to be_false
      expect(subject.allow?(:users, :invite_friends, target_user)).to be_false
    end

    it 'anonymous permissions for recommendations' do 
      expect(subject.allow?(:recommendations, :latest)).to be_false
      expect(subject.allow?(:recommendations, :career)).to be_false
      expect(subject.allow?(:recommendations, :emotion)).to be_false
      expect(subject.allow?(:recommendations, :actions)).to be_false
    end

    it 'anonymous permissions for preferences' do 
      expect(subject.allow?(:preferences, :show)).to be_false
      expect(subject.allow?(:preferences, :create)).to be_false
      expect(subject.allow?(:preferences, :update)).to be_false      
    end

    it 'anonymous permissions for preorders' do
      expect(subject.allow?(:preorders, :create)).to be_false
    end

    it 'anonymous permissions for connections' do
      expect(subject.allow?(:connections, :index)).to be_false
      expect(subject.allow?(:connections, :synchronize)).to be_false
      expect(subject.allow?(:connections, :progress)).to be_false
      expect(subject.allow?(:connections, :destroy)).to be_false
    end

    it 'anonymous permissions for activities' do
      expect(subject.allow?(:activities, :index)).to be_false
    end

    it 'anonymous permissions for sleeps' do
      expect(subject.allow?(:sleeps, :index)).to be_false
    end

    it 'anonymous permissions for friends' do 
      expect(subject.allow?(:friends, :index)).to be_false
      expect(subject.allow?(:friends, :find)).to be_false
      expect(subject.allow?(:friends, :accept)).to be_false
      expect(subject.allow?(:friends, :pending)).to be_false
      expect(subject.allow?(:friends, :invite)).to be_false
      expect(subject.allow?(:friends, :reject)).to be_false
      expect(subject.allow?(:friends, :unfriend)).to be_false
    end

    it 'anonymous permissions for leaderboards' do 
      expect(subject.allow?(:leaderboards, :global)).to be_false
      expect(subject.allow?(:leaderboards, :friends)).to be_false
    end

    it 'anonymous permissions for activity stream' do 
      expect(subject.allow?(:activity_stream, :index)).to be_false
    end

    it 'anonymous permissions for comments' do 
      expect(subject.allow?(:comments, :index)).to be_false
      expect(subject.allow?(:comments, :show)).to be_false
      expect(subject.allow?(:comments, :create)).to be_false
      expect(subject.allow?(:comments, :update)).to be_false
      expect(subject.allow?(:comments, :destroy)).to be_false
    end

    it 'anonymous permissions for highfives' do 
      expect(subject.allow?(:highfives, :index)).to be_false
      expect(subject.allow?(:highfives, :create)).to be_false
      expect(subject.allow?(:highfives, :destroy)).to be_false
    end

  end
end
