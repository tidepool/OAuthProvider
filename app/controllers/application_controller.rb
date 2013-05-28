class ApplicationController < ActionController::Base
  protect_from_forgery

end

class Api::V1::UnauthorizedError < StandardError
end

