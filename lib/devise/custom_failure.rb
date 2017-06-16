module Devise
  class CustomFailure < ::Devise::FailureApp
    def redirect_url
      cas.new_user_session_url
    end

    # You need to override respond to eliminate recall
    def respond
      if http_auth?
        http_auth
      else
        redirect
      end
    end
  end
end
