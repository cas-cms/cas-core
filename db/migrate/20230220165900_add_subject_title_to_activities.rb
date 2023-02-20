class AddSubjectTitleToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_activities, :user_description, :string
    add_column :cas_activities, :subject_description, :string
  end
end
