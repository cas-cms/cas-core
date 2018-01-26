module Cas
  class Sites::Sections::ApplicationController < Sites::ApplicationController
    before_action :load_section

    private

    def load_section
      @section ||= @site.sections.friendly.find(params[:section_id])
    end

    def scope_content_by_role(model_relation = ::Cas::Content)
      # Only admins and editors can see other people's content
      if !current_person.admin? && !current_person.editor?
        model_relation = model_relation.where(author_id: current_person.id)
      end
      model_relation
    end

    def load_categories
      @categories ||= @section.categories
    end
  end
end
