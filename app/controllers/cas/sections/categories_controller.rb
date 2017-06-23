require_dependency "cas/application_controller"

module Cas
  class Sections::CategoriesController < Sections::ApplicationController
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      @categories = @section.categories
    end

    def new
      @category = Cas::Category.new
    end

    def edit
    end

    def create
      @category = Cas::Category.new(category_params)
      @category.section = @section

      if @category.save
        redirect_to section_categories_url(@section), notice: 'Categoria salva com sucesso.'
      else
        render :new
      end
    end

    def update
      if @category.update(category_params)
        redirect_to section_categories_url(@section), notice: 'Categoria salva com sucesso.'
      else
        render :edit
      end
    end

    private

    def set_category
      @category = Cas::Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name)
    end
  end
end
