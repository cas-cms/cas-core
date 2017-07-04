module Cas
  class Sections::ApplicationController < ApplicationController
    before_action :load_section

    private

    def load_section
      @section ||= ::Cas::Section.friendly.find(params[:section_id])
    end

    def scope_content_by_role(model_relation = ::Cas::Content)
      # Only admins and editors can see other people's content
      if !current_user.admin? && !current_user.editor?
        model_relation = model_relation.where(author_id: current_user.id)
      end
      model_relation
    end

    def load_categories
      @categories ||= @section.categories
    end
  end
end
