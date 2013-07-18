require 'spec_helper'

module Permissions
  describe RegisteredUserPermission do
    
    describe 'caller and target_user are the same user' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) } 
      let(:game) { create(:game, user: user) }
      let(:others_game) { create(:game, user: other_user) }
      subject { Permissions.permission_for(user, user) }

      it 'registered user permissions for games' do
        expect(subject.allow?(:games, :create)).to be_true
        expect(subject.allow?(:games, :destroy, game)).to be_true
        expect(subject.allow?(:games, :destroy, others_game)).to be_false
        expect(subject.allow?(:games, :update, game)).to be_true
        expect(subject.allow?(:games, :update, others_game)).to be_false
        expect(subject.allow?(:games, :show, game)).to be_true
        expect(subject.allow?(:games, :show, others_game)).to be_false
        expect(subject.allow?(:games, :index)).to be_true
        expect(subject.allow?(:games, :latest, game)).to be_true
        expect(subject.allow?(:games, :latest, others_game)).to be_false
      end

      it 'registered user permissions for results' do
        expect(subject.allow?(:results, :index)).to be_true
        expect(subject.allow?(:results, :show, game)).to be_true
        expect(subject.allow?(:results, :show, others_game)).to be_false
        expect(subject.allow?(:results, :progress, game)).to be_true
        expect(subject.allow?(:results, :progress, others_game)).to be_false
      end

      it 'registered user permissions for users' do 
        target_user = user
        expect(subject.allow?(:users, :show, target_user)).to be_true
        expect(subject.allow?(:users, :create, target_user)).to be_true
        expect(subject.allow?(:users, :update, target_user)).to be_true
        expect(subject.allow?(:users, :destroy, target_user)).to be_true
        expect(subject.allow?(:users, :personality, target_user)).to be_true
      end

      it 'registered user permissions for recommendations' do
        expect(subject.allow?(:recommendations, :latest)).to be_true
        expect(subject.allow?(:recommendations, :career)).to be_true
        expect(subject.allow?(:recommendations, :emotion)).to be_true
        expect(subject.allow?(:recommendations, :actions)).to be_true
      end

      it 'registered user permissions for preferences' do 
        expect(subject.allow?(:preferences, :show)).to be_true
        expect(subject.allow?(:preferences, :create)).to be_true
        expect(subject.allow?(:preferences, :update)).to be_true      
      end


      it 'registered user permissions for preorders' do
        expect(subject.allow?(:preorders, :create)).to be_true
      end

      it 'registered user permissions for connections' do
        expect(subject.allow?(:connections, :index)).to be_true
      end
    end

    # describe 'caller and target_user are NOT the same user' do
    #   let(:user) { create(:user) }
    #   let(:other_user) { create(:user) } 
    #   let(:game) { create(:game, user: user) }
    #   let(:others_game) { create(:game, user: other_user) }
    #   subject { Permissions.permission_for(user, other_user) }

    #   it 'registered user permissions for games' do
    #     expect(subject.allow?(:games, :create)).to be_false
    #     expect(subject.allow?(:games, :destroy, game)).to be_false
    #     expect(subject.allow?(:games, :destroy, others_game)).to be_false
    #     expect(subject.allow?(:games, :update, game)).to be_false
    #     expect(subject.allow?(:games, :update, others_game)).to be_false
    #     expect(subject.allow?(:games, :show, game)).to be_false
    #     expect(subject.allow?(:games, :show, others_game)).to be_false
    #     expect(subject.allow?(:games, :index)).to be_false
    #     expect(subject.allow?(:games, :latest, game)).to be_false
    #     expect(subject.allow?(:games, :latest, others_game)).to be_false
    #   end

    #   it 'registered user permissions for results' do
    #     expect(subject.allow?(:results, :show, game)).to be_false
    #     expect(subject.allow?(:results, :show, others_game)).to be_false
    #     expect(subject.allow?(:results, :progress, game)).to be_false
    #     expect(subject.allow?(:results, :progress, others_game)).to be_false
    #   end

    #   it 'registered user permissions for users' do 
    #     target_user = other_user
    #     expect(subject.allow?(:users, :show, target_user)).to be_false
    #     expect(subject.allow?(:users, :create, target_user)).to be_false
    #     expect(subject.allow?(:users, :update, target_user)).to be_false
    #     expect(subject.allow?(:users, :destroy, target_user)).to be_false
    #     expect(subject.allow?(:users, :personality, target_user)).to be_false
    #   end

    #   it 'registered user permissions for recommendations' do
    #     expect(subject.allow?(:recommendations, :latest)).to be_false
    #     expect(subject.allow?(:recommendations, :career)).to be_false
    #     expect(subject.allow?(:recommendations, :emotion)).to be_false
    #     expect(subject.allow?(:recommendations, :actions)).to be_false
    #   end

    #   it 'registered user permissions for preferences' do 
    #     expect(subject.allow?(:preferences, :show)).to be_false
    #     expect(subject.allow?(:preferences, :create)).to be_false
    #     expect(subject.allow?(:preferences, :update)).to be_false      
    #   end


    #   it 'registered user permissions for preorders' do
    #     expect(subject.allow?(:preorders, :create)).to be_false
    #   end
    # end
  end
end