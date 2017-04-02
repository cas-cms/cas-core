module Cas
  class Sections::ContentsController < ApplicationController
    def index
      @section = Section.find(params[:section_id])
      @contents = @section.contents 
    end

    def new
      @section = Section.find(params[:section_id])
      @content = Cas::Content.new
      
    end

    def create
      @content = Cas::Content.new(content_params)
      @section = Section.find(params[:section_id])
      @content.section_id = @section.id
      @content.save
      redirect_to section_contents_url(@section)
    end

    private

    def content_params
      params.require(:content).permit(:title, :text)
    end

  end
end