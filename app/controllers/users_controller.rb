class UsersController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  before_action :require_login, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      # Auto-login with Authlogic
      UserSession.create(@user)
      flash[:notice] = "Welcome to the Blog, #{@user.name}!"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    if @user.update(user_params)
      flash[:notice] = "Profile updated successfully."
      redirect_to root_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end


