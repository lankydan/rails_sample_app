# hqndles sessions of users for the site
class SessionsController < ApplicationController

  def new
  end

  def create
    session = params[:session]
    @user = User.find_by(email: session[:email].downcase)
    if @user && @user.authenticate(session[:password])
      if @user.activated?
        log_in @user
        session[:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        flash[:warning] = 'Account not activated! Check your email for the activation link.'
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email and password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  private def session_params
    params.require(:session).permit(:email, :password)
  end

end
