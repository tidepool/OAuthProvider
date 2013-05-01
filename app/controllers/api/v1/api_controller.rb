class Api::V1::ApiController < ApplicationController
  protected

  def current_resource_owner
    if doorkeeper_token
      @current_resource_owner ||= User.includes(:profile_description).find(doorkeeper_token.resource_owner_id)
    else
      @current_resource_owner = nil
    end
  end
end
