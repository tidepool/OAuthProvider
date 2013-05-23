require 'spec_helper'

module Permissions

  describe AdminPermission do
    let(:user) { create(:admin) }
    let(:other_user) { create(:user) } 
    let(:assessment) { create(:assessment, user: user) }
    let(:others_assessment) { create(:assessment, user: other_user) }
    subject { Permissions.permission_for(user, other_user) }

    it 'allows assessments' do
      should allow(:assessments, :create)
      should allow(:assessments, :destroy, assessment)
      should allow(:assessments, :destroy, others_assessment)
      should allow(:assessments, :update, assessment)
      should allow(:assessments, :update, others_assessment)
      should allow(:assessments, :show, assessment)
      should allow(:assessments, :show, others_assessment)
      should allow(:assessments, :index)
      should allow(:assessments, :latest, assessment)
      should allow(:assessments, :latest, others_assessment)
      should allow(:assessments, :latest_with_profile, assessment)
      should allow(:assessments, :latest_with_profile, others_assessment)
    end

    it 'allows results' do
      should allow(:results, :create, assessment)
      should allow(:results, :create, others_assessment)
      should allow(:results, :show, assessment)
      should allow(:results, :show, others_assessment)
      should allow(:results, :progress, assessment)
      should allow(:results, :progress, others_assessment)
    end

    it 'allows users' do 
      target_user = other_user
      should allow(:users, :show, target_user)
      should allow(:users, :create, target_user)
      should allow(:users, :update, target_user)
      should allow(:users, :destroy, target_user)
    end

  end
end