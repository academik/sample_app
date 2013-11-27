 class UsersController < ApplicationController
  before_action :signed_in_user,  only: [:index, :edit, :update] #applies only to editing / updating a user
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: :destroy

  def new
  	if current_user.nil?
      @user = User.new 
    else 
      flash[:notice] = "You already have a user.  Sign out to create a new user."
      redirect_to(root_url)
    end
  end

  def show
  	@user = User.find(params[:id])
  end

  def create
  	if current_user.nil?
      @user = User.new(user_params)
    	if @user.save
        sign_in @user
    		flash[:success] = "Welcome to the Sample App!"
    		redirect_to @user
    	else
    		render 'new'
    	end # --- if @user.save... --- 
    else
      flash[:notice] = "You already have a user.  Sign out to create a new user."
      redirect_to(root_url)
    end

  end

  def edit
    #@user set by correct_user
  end

  def update
    #@user set by correct_user
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end
  
  def destroy
    User.find(params[:id]).destroy #seek and destroy on one line! 
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  private

  	def user_params
  		#define what's required, and what's permitted
  		# we want the parameters to have a :user attribute, and we want to allow the other attributes to be changed, but no others. 
  		params.require(:user).permit(:name, :email, :password, :password_confirmation)
  	end

    def signed_in_user
      store_location
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end

    def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end


end
