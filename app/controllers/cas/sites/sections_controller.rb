module Cas
  class Sites::SectionsController < Sites::Sections::ApplicationController
    def index
      @sections = Section.all
    end
  end
end
