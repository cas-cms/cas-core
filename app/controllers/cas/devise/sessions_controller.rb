module Cas
  module Devise
    class SessionsController < ::Devise::SessionsController
      def after_sign_out_path_for(resource_or_scope)
        cas.root_path
      end
    end
  end
end
