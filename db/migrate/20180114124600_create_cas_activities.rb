class CreateCasActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_activities, id: :uuid do |t|
      t.uuid :site_id
      t.uuid :user_id
      t.string :event_name
      t.uuid :subject_id
      t.string :subject_type

      t.timestamps
    end
    add_index :cas_activities, :site_id
    add_index :cas_activities, :user_id
    add_index :cas_activities, [:subject_id, :subject_type]
  end
end
