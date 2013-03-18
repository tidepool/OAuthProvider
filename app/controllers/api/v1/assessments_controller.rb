require 'pry' if Rails.env.test? || Rails.env.development?

class Api::V1::AssessmentsController < Api::V1::ApiController
  doorkeeper_for :all, :except => :create
  respond_to :json
  before_filter :setup_users

  def index
    @assessments = Assessment.find_all_by_caller_and_user(@caller, @user)

    respond_to do |format|
      format.json { render :json => @assessments, :each_serializer => AssessmentSummarySerializer }
    end
  end

  def show 
    @assessment = Assessment.find_by_caller_and_user(params[:id], @caller, @user)
    respond_to do |format|
      format.json { render :json => @assessment }
    end
  end

  def create
    definition = Definition.find_or_return_default(params[:def_id])
    @assessment = Assessment.create_by_caller(definition, @caller, @user)
    # respond_with @assessment

    respond_to do |format|
      format.json { render :json => @assessment}
    end
  end

  def update
    @assessment = Assessment.find(params[:id])
    attributes = params[:assessment]

    @assessment.update_attributes_with_caller(attributes, @caller)
    # binding.pry
    # respond_with @assessment 
    respond_to do |format|
      format.json { render :json => @assessment}
    end

  end

  private
  def setup_users
    @caller = current_resource_owner
    @user = params[:user_id].nil? ? @caller : User.where('id = ?', params[:user_id]).first
  end
end
