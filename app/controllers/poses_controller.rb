require 'pry'
class PosesController < ApplicationController

helper_method :params
  def new
    if !logged_in?
      flash[:error]= "You must be logged in to list a pose."
      return redirect_to controller:'sessions', action:'new'
    end
    @pose= Pose.new
  end
  def create
      pose= current_user.poses.create(pose_params)
      pose.pic= params[:pose][:pic].original_filename
      pose.save #dont forget this, used inspect element and noticed tht the action dispatch was gettigshown in img tag
      binding.pry
    #@picname= params[:pose][:pic].original_filename #this does not work either
  #binding.pry
      #redirect_to poses_path
      redirect_to "poses/#{pose.id}"
       #pose_path(pose)


# #params[:pose][:pic] has @tempfile and @original_filename
      @filename = params[:pose][:pic].original_filename
file = params[:pose][:pic].tempfile
# .to_path.to_s  #instead of just tempfile ?

File.open("./public/#{@filename}", 'wb') do |f|
f.write(file.read)
end
  end



  def edit
    @pose=Pose.find(params[:id])
    if !logged_in?
      flash[:error]= "You must be logged in to do that."
      return redirect_to controller:'sessions', action:'new'

    end
    if @pose.user_id != current_user.id
      flash[:error]= "You don't have permission to do that."
      return redirect_to poses_path

    end




  end
  def update
    @pose=Pose.find(params[:id])
    @pose.update(pose_params)
    redirect_to pose_path(@pose)
  end
  def destroy
    @pose=Pose.find(params[:id])
    if current_user.id == @pose.user_id
      @pose.delete
      redirect_to poses_path
    else
      redirect_to poses_path
  end
end
  def index
    @user= User.find(session[:user_id]) if session[:user_id]
      #  @poses=Pose.all
@categories= Category.all
   @levels= Level.all

    if !params[:level].blank?
    @poses =  Pose.by_level(params[:level])
  elsif !params[:categories].blank?
         @poses= Pose.by_category(params[:categories])
     else
       @poses = Pose.all
  end
  end

  def show

    @pose=Pose.find(params[:id])
    if @pose.reviews.empty?
        @reviews= "No reviews yet."
    else
    #  binding.pry
      @reviews= @pose.reviews
      #tried doing it here with:
      #@pose.reviews.map do |review|
      #review.user.username says review.content
    #end
    end
      @review= Review.new
  end


private
def pose_params
  params.require(:pose).permit(:name,:content,:pic,:image, :level_id,reviews_attributes: [:content], category_ids:[])
end
end
