class SessionsController < Devise::SessionsController
  respond_to :html

  def new
    puts "Is guest ? #{params[:guest]}"
    super
  end
end