module Cas
  module Devise
    class SessionsController < ::Devise::SessionsController
      include CasDomain

      # Overriding Devise because, for some very misterious reason, it doesn't
      # work in production. It works in some machines, not others, despite using
      # the same containers and environment variables. It is a very specific
      # behavior caused by warden.authenticate!.
      #
      # I spent more time than I'd like on this so I decide for this fix which
      # works as intended and I deem low risk. Devise's controller has been the
      # same for years so I don't expect this to break anytime soon.
      def create
        # We only want the user for the current site (given the domain)
        user = @site.users.find_by(email: params[:user][:email])

        if user && user.valid_password?(params[:user][:password])
          set_flash_message(:notice, :signed_in) if is_navigational_format?
          sign_in(:user, user)
          respond_with user, :location => after_sign_in_path_for(user)
        else
          flash[:error] = "Invalid username or password"
          redirect_to cas.new_user_session_path
        end
      end

      private

      def after_sign_out_path_for(resource_or_scope)
        cas.root_path
      end
    end
  end
end
