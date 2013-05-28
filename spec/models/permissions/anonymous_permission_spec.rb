require 'spec_helper'

module Permissions
  describe AnonymousPermission do    
    let(:other_user) { create(:user) }
    let(:others_game) { create(:game, user: other_user) }
    subject { Permissions.permission_for(nil, other_user) }

    it 'allows games' do
      should_not allow(:games, :create)
      should_not allow(:games, :destroy)
      should_not allow(:games, :update, others_game)
      should_not allow(:games, :show, others_game)
      should_not allow(:games, :index)

      should_not allow(:games, :latest, others_game)
      should_not allow(:games, :latest_with_profile, others_game)
    end

    it 'allows results' do
      should_not allow(:results, :create, others_game)
      should_not allow(:results, :show, others_game)
      should_not allow(:results, :progress, others_game)
    end

    it 'allows users' do 
      target_user = other_user

      should_not allow(:users, :show, target_user)
      should allow(:users, :create)
      should_not allow(:users, :update, target_user)
      should_not allow(:users, :destroy, target_user)
    end
  end
end
