module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    # needs to be called before session.delete
    # or it will retrieve the @current_user again
    # from the current_user method by using the cookies instead
    if logged_in?
      forget current_user
      session.delete(:user_id)
      @current_user = nil
    end
  end

  def current_user
    # @current_user = @current_user || User.find_by(id: session[:user_id])
    # equivalent
    # @current_user ||= User.find_by(id: session[:user_id]) # or equals expression
    # if current_user has a value returns it, otherwise assigns value of find_by
    if (user_id = session[:user_id])
      # if user_id is in the session, then either @current_user is already set
      # or we know the user owns the session but @current_user hasnt been set yet -> so set it
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      # if the user_id is not in the session then check the cookies for the user_id
      user = User.find_by(id: user_id)
      # if the user exists with user_id and its remember_digest matches the hashed version of :remember_token from the cookie
      # then set the @current_user
      # and add the user id to the current session
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end      
  end

  def current_user?(user)
    user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
    # this is equivalent to the above (cookies have a value and an optional expiry date)
    # expiry date set so far into future it mimics being "permanent"
    # cookies[:remember_token] = {value: remember_token, expires: 20.years.from_row.utc }
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # redirects to the stored location or back to the default
  def redirect_back_or(default)
    # forwarding_url will be null if not set in the session
    # which could be due to the last requested url not being a get request
    # if it is nil then goes to the default
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # stores the url trying to be accessed
  def store_location
    # stores the url into the session
    # url taken from the request object
    # stores the url if it is not nil
    session[:forwarding_url] = request.original_url if request.get?
  end

end
