class RelationshipsController < ApplicationController

  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    use_ajax
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    use_ajax
  end

  def use_ajax
    respond_to do |format|
      format.html {redirect_to @user}
      format.js
    end
  end
  

end
