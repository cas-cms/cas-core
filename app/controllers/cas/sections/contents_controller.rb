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

    def edit
      @section = Section.find(params[:section_id])
      @content = Cas::Content.find(params[:id])
    end

    def update
      @section = Section.find(params[:section_id])
      @content = Cas::Content.find(params[:id])
 
      if @content.update(content_params)
        redirect_to section_content_url(@section, @content)
      else
        render 'edit'
      end
    end
 
    private

    def content_params
      params.require(:content).permit(:title, :text)
    end

  end
end