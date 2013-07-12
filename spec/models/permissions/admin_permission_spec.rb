require 'spec_helper'

module Permissions

  describe AdminPermission do
    let(:controller_prefix) { 'api/v1' }
    let(:games) { "#{controller_prefix}/games" }
    let(:results) { "#{controller_prefix}/results" }
    let(:users) { "#{controller_prefix}/users" }
    let(:recommendations) { "#{controller_prefix}/recommendations" }
    let(:preorders) { "#{controller_prefix}/preorders" }
    
    let(:user) { create(:admin) }
    let(:other_user) { create(:user) } 
    let(:game) { create(:game, user: user) }
    let(:others_game) { create(:game, user: other_user) }
    subject { Permissions.permission_for(user, other_user) }

    it 'allows games' do
      should allow(games, :create)
      should allow(games, :destroy, game)
      should allow(games, :destroy, others_game)
      should allow(games, :update, game)
      should allow(games, :update, others_game)
      should allow(games, :show, game)
      should allow(games, :show, others_game)
      should allow(games, :index)
      should allow(games, :latest, game)
      should allow(games, :latest, others_game)
    end

    it 'allows results' do
      should allow(results, :index)
      should allow(results, :show, game)
      should allow(results, :show, others_game)
      should allow(results, :progress, game)
      should allow(results, :progress, others_game)
    end

    it 'allows users' do 
      target_user = other_user
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
      should allow(recommendations, :actions)
    end

    it 'allows preorders' do
      should allow(preorders, :create)
    end

  end
end