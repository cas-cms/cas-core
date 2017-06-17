require_dependency "cas/application_controller"

module Cas
  class Sections::CategoriesController < Sections::ApplicationController
    before_action :set_section_category, only: [:show, :edit, :update, :destroy]

    def index
      @section_categories = Cas::Category.all
    end

    def new
      @section_category = Cas::Category.new
    end

    def edit
    end

    def create
      @section_category = Cas::Category.new(section_category_params)
      @section_category.section = @section

      if @section_category.save
        redirect_to section_categories_url(@section), notice: 'Categoria salva com sucesso.'
      else
        render :new
      end
    end

    def update
      if @section_category.update(section_category_params)
        redirect_to @section_category, notice: 'Categoria salva com sucesso.'
      else
        render :edit
      end
    end

    def destroy
      @section_category.destroy
      redirect_to section_categories_url, notice: 'Categoria excluída com sucesso.'
    end

    private

    def set_section_category
      @section_category = Cas::Category.find(params[:id])
    end

    def section_category_params
      params.require(:category).permit(:name)
    end
  end
end
