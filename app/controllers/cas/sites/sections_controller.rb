module Cas
  class Sites::SectionsController < Sites::ApplicationController
    def index
      @sections = @site.sections.all
    end
  end
end
