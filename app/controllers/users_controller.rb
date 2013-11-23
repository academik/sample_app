class UsersController < ApplicationController
  
  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      sign_in @user
  		flash[:success] = "Welcome to the Sample App!"
  		redirect_to @user
  	else
  		render 'new'
  	end
  end

  private

  	def user_params
  		#define what's required, and what's permitted
  		# we want the parameters to have a :user attribute, and we want to allow the other attributes to be changed, but no others. 
  		params.require(:user).permit(:name, :email, :password, :password_confirmation)
  	end

end
