require_dependency "cas/application_controller"

module Cas
  class Sections::ContentsController < Sections::ApplicationController
    def index
      @contents = @section.contents.order('created_at desc').page(params[:page]).per(25)
    end

    def new
      @content = ::Cas::Content.new
      @categories = @section.categories
    end

    def create
      @content = ::Cas::Content.new(content_params)
      @content.author_id = current_user.id
      @content.section_id = @section.id
      @content.tag_list = content_params[:tag_list]

      if @content.save
        redirect_to section_contents_url(@section), notice: 'Noticia salva com sucesso.'
      else
        render :new
      end
    end

    def edit
      @content = ::Cas::Content.friendly.find(params[:id])
      @categories = @section.categories
    end

    def update
      @content = ::Cas::Content.friendly.find(params[:id])

      if @content.update(content_params)
        redirect_to section_contents_path
      else
        render 'edit'
      end
    end

    def destroy
      @content = ::Cas::Content.friendly.find(params[:id])
      @content.destroy

      redirect_to section_contents_path
    end

    private

    def content_params
      params.require(:content).permit(
        :category_id,
        :title,
        :summary,
        :text,
        :tag_list,
      )
    end
  end
end
