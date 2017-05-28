class MicropostsController < ApplicationController

  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy 

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Post created'
      redirect_to root_url
    else
      # @feed_items is needed if I do not use ajax as the microposts need to be redisplayed
      # as I am using ajax that part of the screen is not refreshed and therefore
      # the items will remain what they were before the action was sent
      if request.xhr?
        render_root
      else
        @feed_items = current_user.feed.paginate(page: params[:page])
        render "static_pages/home"
      end
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = 'Post deleted'
    redirect_to request.referrer || root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

    def render_root
      respond_to do |format|
        format.html { redirect_to root_url }
        format.js
      end
  end

end
