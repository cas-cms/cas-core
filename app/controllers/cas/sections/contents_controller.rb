require_dependency "cas/application_controller"

module Cas
  class Sections::ContentsController < Sections::ApplicationController
    def index
      #@user = Cas::User.find(params[:author_id])
      @contents = @section.contents
    end

    def new
      @content = Cas::Content.new
    end

    def create
      @content = Cas::Content.new(content_params, current_user)
      #@content.category = @category

      binding.pry
      if @content.save
        redirect_to section_contents_url(@content), notice: 'Noticia salva com sucesso.'
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
        redirect_to section_content_url(@section, @content)
      else
        render 'edit'
      end
    end
 
    private

    def content_params
      params.require(:content).permit(:title, :summary, :text)
    end
  end
end
