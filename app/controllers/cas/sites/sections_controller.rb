module Cas
  class Sites::SectionsController < ApplicationController
    def index
      @sections = Section.all
    end
  end
end
