require 'spec_helper'

module Permissions
  describe AnonymousPermission do    
    let(:other_user) { create(:user) }
    let(:others_assessment) { create(:assessment, user: other_user) }
    subject { Permissions.permission_for(nil, other_user) }

    it 'allows assessments' do
      should_not allow(:assessments, :create)
      should_not allow(:assessments, :destroy)
      should_not allow(:assessments, :update, others_assessment)
      should_not allow(:assessments, :show, others_assessment)
      should_not allow(:assessments, :index)

      should_not allow(:assessments, :latest, others_assessment)
      should_not allow(:assessments, :latest_with_profile, others_assessment)
    end

    it 'allows results' do
      should_not allow(:results, :create, others_assessment)
      should_not allow(:results, :show, others_assessment)
      should_not allow(:results, :progress, others_assessment)
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
