require 'spec_helper'

module Permissions
  describe RegisteredUserPermission do
    let(:controller_prefix) { 'api/v1' }
    let(:games) { "#{controller_prefix}/games" }
    let(:results) { "#{controller_prefix}/results" }
    let(:users) { "#{controller_prefix}/users" }
    let(:recommendations) { "#{controller_prefix}/recommendations" }
    let(:preorders) { "#{controller_prefix}/preorders" }

    describe 'caller and target_user are the same user' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) } 
      let(:game) { create(:game, user: user) }
      let(:others_game) { create(:game, user: other_user) }
      subject { Permissions.permission_for(user, user) }

      it 'allows games' do
        should allow(games, :create)
        should allow(games, :destroy, game)
        should_not allow(games, :destroy, others_game)
        should allow(games, :update, game)
        should_not allow(games, :update, others_game)
        should allow(games, :show, game)
        should_not allow(games, :show, others_game)
        should allow(games, :index)
        should allow(games, :latest, game)
        should_not allow(games, :latest, others_game)
      end

      it 'allows results' do
        should allow(results, :index)
        should allow(results, :show, game)
        should_not allow(results, :show, others_game)
        should allow(results, :progress, game)
        should_not allow(results, :progress, others_game)
      end

      it 'allows users' do 
        target_user = user
        should allow(users, :show, target_user)
        should allow(users, :create, target_user)
        should allow(users, :update, target_user)
        should allow(users, :destroy, target_user)
        should allow(users, :personality, target_user)
      end

      it 'allows recommendations' do
        should allow(recommendations, :latest)
        should allow(recommendations, :career)
        should allow(recommendations, :emotion)
      end

      it 'allows preorders' do
        should allow(preorders, :create)
      end

    end

    describe 'caller and target_user are NOT the same user' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) } 
      let(:game) { create(:game, user: user) }
      let(:others_game) { create(:game, user: other_user) }
      subject { Permissions.permission_for(user, other_user) }

      it 'allows games' do
        should_not allow(games, :create)
        should_not allow(games, :destroy, game)
        should_not allow(games, :destroy, others_game)
        should_not allow(games, :update, game)
        should_not allow(games, :update, others_game)
        should_not allow(games, :show, game)
        should_not allow(games, :show, others_game)
        should_not allow(games, :index)
        should_not allow(games, :latest, game)
        should_not allow(games, :latest, others_game)
      end

      it 'allows results' do
        should_not allow(results, :show, game)
        should_not allow(results, :show, others_game)
        should_not allow(results, :progress, game)
        should_not allow(results, :progress, others_game)
      end

      it 'allows users' do 
        target_user = other_user
        should_not allow(users, :show, target_user)
        should_not allow(users, :create, target_user)
        should_not allow(users, :update, target_user)
        should_not allow(users, :destroy, target_user)
        should_not allow(users, :personality, target_user)
      end

      it 'allows recommendations' do
        should_not allow(recommendations, :latest)
        should_not allow(recommendations, :career)
        should_not allow(recommendations, :emotion)
      end

      it 'allows preorders' do
        should_not allow(preorders, :create)
      end

    end

  end
end