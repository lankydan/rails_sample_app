class UsersController < ApplicationController
  
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy] 
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  # User.new(params[:user]) doesnt work since rails 4 due to being insecure
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
     if @user.update_attributes(user_params)
       flash[:success] = "Profile updated!"
      redirect_to @user
    else
      render "edit"
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
  end

  # takes the parameters that you want to use from the params hash and returns them
  # this is safe as only the specified values get passed through
  # no one can inject extra parameters to the URL which might alter the User object
  # called strong parameters
  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def logged_in_user
      unless logged_in? # defined in SessionsHelper
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user?(@user)
    end

    def admin_user
      redirect_to root_url unless current_user.admin?
    end

end