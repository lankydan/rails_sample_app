module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def current_user
    # @current_user = @current_user || User.find_by(id: session[:user_id])
    # equivalent
    @current_user ||= User.find_by(id: session[:user_id]) # or equals expression
    # if current_user has a value returns it, otherwise assigns value of find_by
  end

  def logged_in?
    !current_user.nil?
  end

end
