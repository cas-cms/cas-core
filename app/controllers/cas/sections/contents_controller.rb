module Cas
  class Sections::ContentsController < ApplicationController
    def index
      @section = Section.find(params[:section_id])
    end


  end
end