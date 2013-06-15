module Permissions
  class BasePermission
    def initialize
      # Initialize controller names
      @games = "#{controller_prefix}/games"
      @results = "#{controller_prefix}/results"
      @users = "#{controller_prefix}/users"
      @recommendations = "#{controller_prefix}/recommendations"
    end

    def allow?(controller, action, resource = nil)  
      allowed = @allow_all || (@allowed_actions && @allowed_actions[[controller.to_s, action.to_s]])
      allowed && (allowed == true || resource && allowed.call(resource))
    end

    protected 
    def allow(controllers, actions, &block)
      @allowed_actions ||= {}

      Array(controllers).each do |controller|
        Array(actions).each do |action|
          @allowed_actions[[controller.to_s, action.to_s]] = block || true
        end
      end
    end

    def allow_all
      @allow_all = true
    end

    def controller_prefix
      'api/v1'
    end

  end
end
