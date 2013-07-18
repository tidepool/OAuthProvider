class Api::V1::ConnectionsController < Api::V1::ApiController
  doorkeeper_for :all

  def index
    strategy_list = OmniAuth.all_strategies 

    # [0] OmniAuth::Strategies::Facebook < OmniAuth::Strategies::OAuth2,
    # [1] OmniAuth::Strategies::Twitter < OmniAuth::Strategies::OAuth,
    # [2] OmniAuth::Strategies::Fitbit < OmniAuth::Strategies::OAuth

    connections = []
    strategy_list.each do |strategy|
      provider = /(?<=^OmniAuth::Strategies::)\S*/m.match(strategy.to_s).to_s.downcase
      
      authentication = Authentication.find_by_provider_and_user(provider, target_user)
      activated = !authentication.nil? 
      connections << {
        provider: provider,
        activated: activated
      }
    end

    respond_to do |format|
      format.json { render :json => connections }
    end
  end

  def current_resource
    target_user
  end

end