class Api::V1::UnauthorizedError < StandardError; end
class Api::V1::PreconditionFailedError < StandardError; end
class Api::V1::ExternalConnectionError < ::RuntimeError; end
class Api::V1::ExternalAuthenticationError < ::SecurityError; end
class Api::V1::SyncError < ::RuntimeError; end 
class Api::V1::ResultCalculationError < ::RuntimeError; end
class Api::V1::FriendSurveyNotReadyError < ::RuntimeError; end
class Api::V1::UserEventValidatorError < ::RuntimeError; end