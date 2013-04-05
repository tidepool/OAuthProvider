class UsersController < ApplicationController
  respond_to :html

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      puts "Session in User#create #{session}"
      redirect_to session[:user_return_to], :notice => "Thanks for signing up"
    else
      render "new"
    end
  end
end