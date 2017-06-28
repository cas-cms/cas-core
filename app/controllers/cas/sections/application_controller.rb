module Cas
  class Sections::ApplicationController < ApplicationController
    before_action :load_section

    private

    def load_section
      @section ||= ::Cas::Section.friendly.find(params[:section_id])
    end
  end
end
