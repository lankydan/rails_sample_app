class UserController < ApplicationController
  
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
      redirect_to @user # equivalent to redirect_to user_url(@user)
    else
      render 'new'
    end
  end

  # takes the parameters that you want to use from the params hash and returns them
  # this is safe as only the specified values get passed through
  # no one can inject extra parameters to the URL which might alter the User object
  private def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
