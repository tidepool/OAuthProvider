require 'spec_helper'

module Permissions
  describe GuestPermission do

    describe 'caller and target_user are the same user' do
      let(:user) { create(:guest) }
      let(:other_user) { create(:guest) } 
      let(:assessment) { create(:assessment, user: user) }
      let(:others_assessment) { create(:assessment, user: other_user) }
      subject { Permissions.permission_for(user, user) }

      it 'allows assessments' do
        should allow(:assessments, :create)
        should_not allow(:assessments, :destroy)
        should allow(:assessments, :update, assessment)
        should_not allow(:assessments, :update, others_assessment)
        should allow(:assessments, :show, assessment)
        should_not allow(:assessments, :show, others_assessment)
        should_not allow(:assessments, :index)

        should allow(:assessments, :latest, assessment)
        should_not allow(:assessments, :latest, others_assessment)
        should allow(:assessments, :latest_with_profile, assessment)
        should_not allow(:assessments, :latest_with_profile, others_assessment)
      end

      it 'allows results' do
        should allow(:results, :create, assessment)
        should_not allow(:results, :create, others_assessment)
        should allow(:results, :show, assessment)
        should_not allow(:results, :show, others_assessment)
        should allow(:results, :progress, assessment)
        should_not allow(:results, :progress, others_assessment)
      end

      it 'allows users' do 
        target_user = user

        should allow(:users, :show, target_user)

        should_not allow(:users, :create, target_user)
        should_not allow(:users, :update, target_user)
        should_not allow(:users, :destroy, target_user)
      end
    end

    describe 'caller and target_user are not the same user' do
      let(:user) { create(:guest) }
      let(:other_user) { create(:guest) } 
      let(:assessment) { create(:assessment, user: user) }
      let(:others_assessment) { create(:assessment, user: other_user) }
      subject { Permissions.permission_for(user, other_user) }

      it 'allows assessments' do
        should_not allow(:assessments, :create)
        should_not allow(:assessments, :destroy)
        should_not allow(:assessments, :update, assessment)
        should_not allow(:assessments, :update, others_assessment)
        should_not allow(:assessments, :show, assessment)
        should_not allow(:assessments, :show, others_assessment)
        should_not allow(:assessments, :index)

        should_not allow(:assessments, :latest, assessment)
        should_not allow(:assessments, :latest, others_assessment)
        should_not allow(:assessments, :latest_with_profile, assessment)
        should_not allow(:assessments, :latest_with_profile, others_assessment)
      end

      it 'allows results' do
        should_not allow(:results, :create, assessment)
        should_not allow(:results, :create, others_assessment)
        should_not allow(:results, :show, assessment)
        should_not allow(:results, :show, others_assessment)
        should_not allow(:results, :progress, assessment)
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
end