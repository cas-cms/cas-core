require_dependency "cas/application_controller"

module Cas
  class Sections::ContentsController < Sections::ApplicationController

    def index
      @contents = @section.contents
    end

    def new
      @content = Cas::Content.new
    end

    def create
      @content = Cas::Content.new(content_params)
      @content.author_id = current_user.id
      @content.section_id = @section.id

      if @content.save
        redirect_to section_contents_url(@section, @content), notice: 'Noticia salva com sucesso.'
      else
        render :new
      end
    end

    def edit
      @section = Section.find(params[:section_id])
      @content = Cas::Content.find(params[:id])
    end

    def update
      @section = Section.find(params[:section_id])
      @content = Cas::Content.find(params[:id])
 
      if @content.update(content_params)
        redirect_to section_contents_path
      else
        render 'edit'
      end
    end
 
    private

    def content_params
      params.require(:content).permit(:title, :summary, :text, :author_id)
    end
  end
end
