require_dependency "cas/application_controller"

module Cas
  class Sections::ContentsController < Sections::ApplicationController
    class ImageBelongsToAnotherAttachable < StandardError; end

    def index
      @contents = scope_content_by_role(@section.contents)
      @contents = @contents.order('created_at desc').page(params[:page]).per(25)
    end

    def new
      @content = ::Cas::Content.new
      load_categories
    end

    def create
      @content = ::Cas::Content.new(content_params)

      success = nil
      begin
        ActiveRecord::Base.transaction do
          @content.author_id = current_user.id
          @content.section_id = @section.id
          @content.tag_list = content_params[:tag_list]
          success = @content.save!
          associate_images(@content)
        end
      rescue ActiveRecord::RecordInvalid
        success = nil
      end

      if success
        redirect_to section_contents_url(@section), notice: 'Noticia salva com sucesso.'
      else
        load_categories
        render :new
      end
    end

    def edit
      @content = scope_content_by_role.friendly.find(params[:id])
      load_categories
    end

    def update
      @content = scope_content_by_role.friendly.find(params[:id])

      success = nil
      begin
        ActiveRecord::Base.transaction do
          @content.tag_list = content_params[:tag_list]
          success = @content.update!(content_params)
          associate_images(@content)
        end
      rescue ActiveRecord::RecordInvalid
        success = nil
      end

      if success
        redirect_to section_contents_path
      else
        load_categories
        render :edit
      end
    end

    def destroy
      @content = scope_content_by_role.friendly.find(params[:id])
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
        :url,
        :tag_list,
      )
    end

    def associate_images(item)
      return if params[:images].blank?

      ActiveRecord::Base.transaction do
        params[:images][:files].to_unsafe_h.each do |key, value|
          next if value["id"].blank?
          begin
            new_order = key.to_i + 1
            is_cover = params[:images][:cover_id] == value["id"]
            image = ::Cas::MediaFile.find(value["id"])
            if image.attachable.blank?
              image.update!(cover: is_cover, order: new_order, attachable: item)
            elsif image.order.to_i != new_order || image.cover != is_cover
              image.update!(cover: is_cover, order: new_order)
            elsif image.attachable != item
              raise ImageBelongsToAnotherAttachable, "Image already belongs to #{item.attachable.id}"
            end
          rescue ActiveRecord::RecordNotFound
          end
        end
      end
    end
  end
end
