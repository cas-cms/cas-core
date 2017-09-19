module Cas
  class IncrementPageviewsJob
    include ::Sidekiq::Worker

    def perform(id, type)
      if type == "content"
        Cas::Content.find(id).increment!(:pageviews)
      end
    end
  end
end
