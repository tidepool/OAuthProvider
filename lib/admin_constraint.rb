class AdminConstraint
  def matches?(request)
    return false unless request.session[:admin_id]
    @user ||= Admin.find request.session[:admin_id]
    @user
  end
end