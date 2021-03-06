class SessionsController < ApplicationController
  def login_form
  end

  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end
  #

  def login
    auth_hash = request.env['omniauth.auth']
    user = User.from_github(auth_hash)

    #attempt to find these credentials in our DB
    user = User.find_by(oauth_provider: params[:provider], oauth_uid: auth_hash["uid"])
    if user.nil?
    # Don't know this user, build a new user
      user = User.from_github(auth_hash)
      if user.save
        session[:user_id] = user.id
        flash[:result_text] = "Successfully logged in as new user: #{user.username}"
      else
        flash[:result_text] = "Login unsuccessful"
        user.errors.messages.each do |field, problem|
          flash[:field] = problem.join(', ')
        end
      end
    else
      #Welcome back!
      session[:user_id] = user.id
      flash[:result_text] = "Welcome back, #{user.username}"
    end
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
