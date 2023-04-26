require_dependency "cas/application_controller"

module Cas
  class Sites::Sections::ContentsController < Sites::Sections::ApplicationController
    class FileBelongsToAnotherAttachable < StandardError; end
    before_action :set_content_type

    def index
      @contents = scope_content_by_role(@section.contents)
      @contents = @contents.order('created_at desc').page(params[:page]).per(25)
    end

    def new
      @content = ::Cas::Content.new
      @content.content_to_content.build
      load_categories
    end

    def create
      @content = ::Cas::Content.new(content_params)
      @content.author_id = current_user.id
      @content.section_id = @section.id

      success = nil
      begin
        ActiveRecord::Base.transaction do
          success = serialize_form_value_into_models
        end
      rescue ActiveRecord::RecordInvalid
        Rails.logger.info "Errors: #{@content.errors.full_messages.inspect}"
        success = nil
      end

      if success
        redirect_to site_section_contents_url(@site, @section), notice: 'Noticia salva com sucesso.'
      else
        load_categories
        render :new
      end
    end

    def edit
      @content = scope_content_by_role.friendly.find(params[:id])

      if @content.created_at.present? && @content.date.blank?
        @default_date = @content.created_at
      else
        @default_date = @content.date
      end

      load_categories
    end

    def update
      @content = scope_content_by_role.friendly.find(params[:id])

      success = nil
      begin
        ActiveRecord::Base.transaction do
          success = serialize_form_value_into_models
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.info "Content Invalid: #{e.message} - #{@content.errors.inspect}"
        success = nil
      end

      if success
        redirect_to site_section_contents_url(@site, @section)
      else
        load_categories
        render :edit
      end
    end

    def destroy
      @content = scope_content_by_role.friendly.find(params[:id])
      @content.destroy

      redirect_to site_section_contents_url(@site, @section)
    end

    private

    def set_content_type
      @content_type = @section.section_type
    end

    def content_params
      @content_params ||= begin
        # When no file is uploaded, when the content form is submitted the
        # `file` input ends up being sent empty (e.g file: [""]). This confuses
        # Rails.
        if params[:content][:file].present?
          params[:content].delete(:file) if params[:content][:file].map(&:presence)&.compact.blank?
        end

        result = params.require(:content).permit(
          :category_id,
          :title,
          :location,
          :summary,
          :published,
          :date,
          :text,
          :url,
          :embedded,
          :tag_list,
          :file,
          :content_to_content
        )

        if result[:content_to_content].present?
          result[:content_to_content] = result[:content_to_content].split(",").map { |id|
            # Params comes like this:
            #
            # {
            #   content_to_content: "f0ba2d53-07ba-4e66-be76-edbcfc2559a5,7719b57e-fc23-45dc-8a42-faec74806b80"
            # }
            Cas::ContentToContent.new(cas_other_content_id: id)
          }
        else
          result[:content_to_content] = []
        end

        unless result.keys.map(&:to_sym).include?(:published)
          result[:published] = true
        end

        if params.dig(:content, :metadata).present?
          # TODO the survey is sending empty questions and these
          # are being saved anyway. We need to filter these.
          result[:metadata] = params.dig(:content, :metadata).to_unsafe_h
        end

        result
      end
    end

    # This is called by create and update methods and do basically the same
    # thing except for one being a `save!` and the other being an `update!`
    def serialize_form_value_into_models
      event = @content.new_record? ? :create : :update

      @content.tag_list = content_params[:tag_list] if content_params[:tag_list]
      associate_related_content(@content)
      Rails.logger.info "Errors: #{@content.errors.inspect}"

      success = if event == :create
                  @content.save!
                else
                  @content.update!(content_params)
                end

      associate_files(@content, :images)
      associate_files(@content, :attachments)

      ::Cas::Activity.create!(
        user: current_user,
        site: @site,
        subject: @content,
        event_name: event
      )

      success
    end

    # This takes what we got in params's `content_to_content` and assigns in
    # @content.
    def associate_related_content(content)
      return if params.dig(:content, :content_to_content).blank?

      content.content_to_content = []
      content_params[:content_to_content]&.each do |content_to_content|
        content.content_to_content << content_to_content
      end
    end

    # form_key_name could be :images or :attachments
    def associate_files(item, form_key_name)
      return if params[form_key_name].blank?

      ActiveRecord::Base.transaction do
        params[form_key_name][:files].to_unsafe_h.each do |key, value|
          next if value["id"].blank?
          begin
            new_order = key.to_i + 1
            is_cover = params[form_key_name][:cover_id] == value["id"]
            image = ::Cas::MediaFile.find(value["id"])
            if image.attachable.blank?
              image.update!(cover: is_cover, order: new_order, attachable: item)
            elsif image.order.to_i != new_order || image.cover != is_cover
              image.update!(cover: is_cover, order: new_order)
            elsif image.attachable != item
              raise FileBelongsToAnotherAttachable, "File already belongs to #{item.attachable.id}"
            end
          rescue ActiveRecord::RecordNotFound
          end
        end
      end
    end
  end
end
