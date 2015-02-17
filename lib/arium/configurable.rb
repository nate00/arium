require 'active_support/configurable'

module Arium
  module Configurable
    extend ActiveSupport::Concern
    include ActiveSupport::Configurable

    def configure
      yield config
    end

    module ClassMethods
      def with_config(hash, *other_args)
        new(*other_args).tap do |instance|
          hash.each do |key, value|
            instance.config[key] = value
          end
        end
      end
    end
  end
end
