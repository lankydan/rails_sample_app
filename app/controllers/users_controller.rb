class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy,
                                        :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to(root_url) && return unless @user.activated?
  end

  def new
    @user = User.new
  end

  # User.new(params[:user]) doesnt work since rails 4 due to being insecure
  def create
    @user = User.new(user_params)
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty!")
      render_new
    elsif @user.save
      @user.send_activation_email
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url
    else
      render_new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated!'
      redirect_to @user
    else
      render_edit
    end
  end

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
  end

  def following
    @title = 'Following'
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  # takes the parameters that you want to use from the params hash and returns them
  # this is safe as only the specified values get passed through
  # no one can inject extra parameters to the URL which might alter the User object
  # called strong parameters
  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

  def render_new
    if request.xhr?
      respond_to do |format|
        format.html { redirect_to signup_url }
        format.js
      end
    else
      render "new"
    end
  end

  def render_edit
    if request.xhr?
      respond_to do |format|
        format.html { redirect_to edit_user_path(@user) }
        format.js
      end
    else
      render "edit"
    end
  end

end
