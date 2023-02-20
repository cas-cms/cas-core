module Cas
  class Activity < ApplicationRecord
    belongs_to :site
    belongs_to :user, optional: true
    belongs_to :subject, polymorphic: true

    # To prevent losing data in case the subject is ever destroyed
    before_validation :cache_description

    private

    def cache_description
      if self.user_description.blank?
        user_string = [user.name]
        user_string << ["(admin)"] if user.admin?
        self.user_description = user_string.join(" ")
      end

      if self.subject_description.blank?
        subject_string = []
        if subject.respond_to?(:title)
          subject_string << [subject.title]
        elsif subject.respond_to?(:name)
          subject_string << [subject.name]
        end
        self.subject_description = subject_string.join(" ")
      end
    end
  end
end
