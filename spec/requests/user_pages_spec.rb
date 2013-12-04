require 'spec_helper'

	describe "UserPages" do

		subject { page }

		describe "index" do
			
			let(:user) {FactoryGirl.create(:user) }
			
			before(:each) do
				sign_in user
				visit users_path
			end

			it { should have_title('All users') }
			it { should have_content('All users') }

			describe "pagination" do
				before(:all)	{30.times {FactoryGirl.create(:user) } }
				after(:all) 	{User.delete_all }

				it {should have_selector('div.pagination') }

				it "should list each user" do 
					User.paginate(page: 1).each do |user|
						expect(page).to have_selector('li', text:user.name)
					end # --- User.paginate --- 

				end # --- it should list each user --- 

			end # --- describe pagination --- 

			describe "delete links" do

				it { should_not have_link('delete') }

				describe "as an admin user" do 
					let(:admin) { FactoryGirl.create(:admin) }
					before do	
						sign_in admin
						visit users_path
					end # --- before do --- 

					it { should have_link('delete', href: user_path(User.first)) }
					
					it "should be able to delete another user" do 
						expect do
							click_link('delete', match: :first)
						end.to change(User, :count).by(-1)
					end # --- it should be able to... --- 
				
					it { should_not	have_link('delete', href:user_path(admin)) }
			
				end# --- describe "as an admin user" 

			end # --- describe delete links --- 

		end # --- describe index --- 

		describe "profile page" do
		  let (:user) 	{ FactoryGirl.create (:user) }
		  let!(:m1)		{ FactoryGirl.create(:micropost, user: user, content: "Foo") }
		  let!(:m2) 	{ FactoryGirl.create(:micropost, user: user, content: "Bar") }

		  before { visit user_path(user) }

		  it { should have_content(user.name) }
		  it { should have_title(user.name) }

		  describe "microposts" do
		  	it { should have_content(m1.content) }
		  	it { should have_content(m2.content) }
		  	it { should have_content(user.microposts.count) }
		  end

		  describe "follow / unfollow buttons" do
		  	let(:other_user) { FactoryGirl.create(:user) }
		  	before { sign_in user }  

		  	describe "following a user" do 
		  		before { visit user_path(other_user) }

		  		it "should increment the followed user count" do
		  			expect do
		  				click_button "Follow"
		  			end.to change(user.followed_users, :count).by(1)
		  		end # --- it "should increment the followed..." --- 

		  		it "should incremeent the other user's followers count" do
		  			expect do
		  				click_button "Follow"
		  			end.to change(other_user.followers, :count).by(1)
		  		end

		  		describe "toggling the button" do
		  			before { click_button "Follow" }
		  			it { should have_xpath("//input[@value='Unfollow']") }
		  		end
		  	end

		  	describe "unfollowing a user" do
		  		before do
		  			user.follow!(other_user)
		  			visit user_path(other_user)
		  		end

		  		it "should decrememnt the followed user count" do
		  			expect do
		  				click_button "Unfollow"
		  			end.to change(user.followed_users, :count).by(-1)
		  		end

		  		it "should decrement the other user's followers count" do
		  			expect do
		  				click_button "Unfollow"
		  			end.to change(other_user.followers, :count).by(-1)
		  		end

		  		describe "toggling the button" do 
		  			before { click_button "Unfollow" }
		  			it { should have_xpath("//input[@value='Follow']") }
		  		end
		  		
		  	end # --- describe unfollowing a user --- 
		  
		  end # --- describe "follow/unfollow buttons" do --- 

		end # --- describe profile page --- 


		describe "signup page" do
	    	before { visit signup_path }

	    	it { should have_content('Sign Up') }
	    	it { should have_title(full_title('Sign Up')) }
	  	end

	  	describe "signup" do

	    	before { visit signup_path }

	    	let (:submit) {"Create my account"}

	    	describe "with invalid information" do
	    		it "should not create a user" do
	    			expect { click_button submit }.not_to change(User, :count)
	    		end
	    	end
	    	
	    	describe "with valid information" do
	    		before do
	    			fill_in "user[name]",	with:"Example User"
	    			fill_in "user[email]", 		with:"user@example.com"
	    			fill_in "user[password]", 	with:"foobar"
	    			fill_in "user[password_confirmation]", with:"foobar"
	    		end

	    		it "should create a user" do		
	    			expect { click_button submit }.to change(User, :count)
	    		end

	    		describe "after saving the user" do
	    			before { click_button submit }
	    			let(:user) { User.find_by(email: 'user@example.com') }

	    			it { should have_link('Sign out') }
	    			it { should have_title(user.name) }
	    			it { should have_selector('div.alert.alert-success', text: 'Welcome') }
	    		end
	    	end

	  	end

	  	describe "edit" do
	  		let(:user) { FactoryGirl.create(:user) }
	  		before do
	  			sign_in user
	  			visit edit_user_path(user)
	  		end

	  		describe "page" do
	  			it { should have_content("Update your profile") }
	  			it { should have_title("Edit user") }
	  			it { should have_link('change', href: 'http://gravatar.com/emails') }
	  		end

	  		describe "with invalid information" do
	  			before { click_button "Save changes" }
	  			it { should have_content('error') }
			end

			describe "with valid information" do
				let(:new_name) 	{ "New Name" }
				let(:new_email) { "new@example.com" }
				before do
					fill_in "user_name",					with: new_name
					fill_in	"user_email", 					with: new_email
					fill_in "user_password",				with: user.password
					fill_in "user_password_confirmation", 	with: user.password
					click_button "Save changes"
				end

				it { should have_title(new_name) }
				it { should have_selector('div.alert.alert-success') }
				it { should have_link('Sign out', href: signout_path) }
				specify { expect(user.reload.name).to eq new_name } # reloads value from db to ensure it updated
				specify { expect(user.reload.email).to eq new_email } # reloads value from db to ensure it updated
			end # --- describe "with valid information" --- 

			describe "forbidden attributes" do
		      let(:params) do
		        { user: { admin: true, password: user.password,
		                  password_confirmation: user.password } }
		      end
		      
		      before do
		        sign_in user, no_capybara: true # sign in 
		        patch user_path(user), params # try to patch the user
		      end

		      specify { expect(user.reload).not_to be_admin }
		    
		    end # --- describe "forbidden attributes"

		end # --- describe EDIT --- 

	describe "following/followers" do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user)}
		before { user.follow!(other_user) }

		describe "followed users" do
			before do
				sign_in user
				visit following_user_path(user)
			end

			it { should have_title(full_title('Following')) }
			it { should have_selector('h3', text: 'Following') }
			it { should have_link(other_user.name, href: user_path(other_user)) }
		end

		describe "followers" do
			before do
				sign_in other_user
				visit followers_user_path(other_user)
			end

			it { should have_title(full_title('Followers')) }
			it { should have_selector('h3', text: 'Followers') }
			it { should have_link(user.name, href: user_path(user)) }
		end # --- describe followers --- 
	end # --- describe "following/followers" do

	describe "micropost associations" do
	    before { @user.save }
	    let!(:older_micropost) do
	      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
	    end
	    let!(:newer_micropost) do
	      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
	    end
	    
	    describe "status" do
	      let(:unfollowed_post) do
	        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
	      end
	      let(:followed_user) { FactoryGirl.create(:user) }

	      before do
	        @user.follow!(followed_user)
	        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
	      end

	      its(:feed) { should include(newer_micropost) }
	      its(:feed) { should include(older_micropost) }
	      its(:feed) { should_not include(unfollowed_post) }
	      its(:feed) do
	        followed_user.microposts.each do |micropost|
	          should include(micropost)
	        end # --- followed_user.microposts.each do --- 
	      end # --- its(:feed) do --- 
	    end # --- describe "Status" --- 
  	end # --- describe "micropost associations" do --- 
end # -- describe User Pages  --- 
