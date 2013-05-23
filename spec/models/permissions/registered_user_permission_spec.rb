require 'spec_helper'

module Permissions
  describe RegisteredUserPermission do

    describe 'caller and target_user are the same user' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) } 
      let(:game) { create(:game, user: user) }
      let(:others_game) { create(:game, user: other_user) }
      subject { Permissions.permission_for(user, user) }

      it 'allows games' do
        should allow(:games, :create)
        should allow(:games, :destroy, game)
        should_not allow(:games, :destroy, others_game)
        should allow(:games, :update, game)
        should_not allow(:games, :update, others_game)
        should allow(:games, :show, game)
        should_not allow(:games, :show, others_game)
        should allow(:games, :index)
        should allow(:games, :latest, game)
        should_not allow(:games, :latest, others_game)
        should allow(:games, :latest_with_profile, game)
        should_not allow(:games, :latest_with_profile, others_game)
      end

      it 'allows results' do
        should allow(:results, :create, game)
        should_not allow(:results, :create, others_game)
        should allow(:results, :show, game)
        should_not allow(:results, :show, others_game)
        should allow(:results, :progress, game)
        should_not allow(:results, :progress, others_game)
      end

      it 'allows users' do 
        target_user = user
        should allow(:users, :show, target_user)
        should allow(:users, :create, target_user)
        should allow(:users, :update, target_user)
        should allow(:users, :destroy, target_user)
      end
    end

    describe 'caller and target_user are NOT the same user' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) } 
      let(:game) { create(:game, user: user) }
      let(:others_game) { create(:game, user: other_user) }
      subject { Permissions.permission_for(user, other_user) }

      it 'allows games' do
        should_not allow(:games, :create)
        should_not allow(:games, :destroy, game)
        should_not allow(:games, :destroy, others_game)
        should_not allow(:games, :update, game)
        should_not allow(:games, :update, others_game)
        should_not allow(:games, :show, game)
        should_not allow(:games, :show, others_game)
        should_not allow(:games, :index)
        should_not allow(:games, :latest, game)
        should_not allow(:games, :latest, others_game)
        should_not allow(:games, :latest_with_profile, game)
        should_not allow(:games, :latest_with_profile, others_game)
      end

      it 'allows results' do
        should_not allow(:results, :create, game)
        should_not allow(:results, :create, others_game)
        should_not allow(:results, :show, game)
        should_not allow(:results, :show, others_game)
        should_not allow(:results, :progress, game)
        should_not allow(:results, :progress, others_game)
      end

      it 'allows users' do 
        target_user = other_user
        should_not allow(:users, :show, target_user)
        should_not allow(:users, :create, target_user)
        should_not allow(:users, :update, target_user)
        should_not allow(:users, :destroy, target_user)
      end
    end

  end
end