module Cas
  module Exceptions
    class Error < StandardError; end

    class UndefinedSite < Cas::Exceptions::Error; end
  end
end
