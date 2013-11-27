module SessionsHelper

	def new
	end

	def create
	end
	
	def sign_in(user)
		remember_token = User.new_remember_token
		cookies.permanent[:remember_token] = remember_token #sets expiration 20 years from now
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		self.current_user = user
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		remember_token = User.encrypt(cookies[:remember_token])
		@current_user ||= User.find_by(remember_token: remember_token) # ||= is "or equals"; 
		#Its effect is to set the @current_user instance variable 
		#to the user corresponding to the remember token, but only if @current_user is undefined. 
	end

	def current_user?(user)
		user == current_user
	end

	def signed_in?
		!current_user.nil?
		# returns true if there is a signed in user. 
		# returns false if there is no current_user.
	end

	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url if request.get? 
	end
	

end
