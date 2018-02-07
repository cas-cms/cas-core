class Cas::ActivitiesController < Cas::ApplicationController
  def index
    @activities = Cas::Activity
      .where(site_id: current_user.sites.map(&:id))
      .order('created_at DESC')
      .page(params[:page])
      .per(25)
  end
end
