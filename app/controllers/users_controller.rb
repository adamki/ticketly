class UsersController < ApplicationController
  include ApplicationHelper

  def new
    @new_user = User.new
  end

  def create
    @user = User.new(user_creation_params)
    if @user.save
      role_assignment(user_creation_params, @user)
      session[:user_id] = @user.id
      flash[:notive] = "Account Created!"
      redirect_router(@user)
    else
      flash[:error] = "Invalid user credentials. Please try again."
      redirect_to login_path
    end
  end

  def dashboard
    @user = User.find(session[:user_id])
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash.notice = "Account Updated!"
      user_dashboard_router(@user)
    else
      flash.now[:errors] = @user.errors.full_messages.join(" ,")
      render :edit
    end
  end

  def destroy
    current_user.user_roles = []
    current_user.destroy
    session.clear
    flash.notice = "Account Deleted!"
    redirect_to root_path
  end

  private

  def user_creation_params
    params.permit(:username, :password, :name, :image, :role, :email)
  end

  def user_params
    params.require(:user).permit(:username, :password, :name, :email, :image)
  end

  def user_dashboard_router(user)
    if user.platform_admin?
      redirect_to platform_admin_dashboard_path
    else
      redirect_to dashboard_path
    end
  end
end
