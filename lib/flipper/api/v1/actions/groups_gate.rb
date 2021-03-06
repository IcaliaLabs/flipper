require 'flipper/api/action'
require 'flipper/api/v1/decorators/feature'

module Flipper
  module Api
    module V1
      module Actions
        class GroupsGate < Api::Action
          include FeatureNameFromRoute

          route %r{\A/features/(?<feature_name>.*)/groups/?\Z}

          def post
            ensure_valid_params
            feature = flipper[feature_name]
            feature.enable_group(group_name)
            decorated_feature = Decorators::Feature.new(feature)
            json_response(decorated_feature.as_json, 200)
          end

          def delete
            ensure_valid_params
            feature = flipper[feature_name]
            feature.disable_group(group_name)
            decorated_feature = Decorators::Feature.new(feature)
            json_response(decorated_feature.as_json, 200)
          end

          private

          def ensure_valid_params
            if group_name.nil? || group_name.empty?
              json_error_response(:name_invalid)
            end

            return if allow_unregistered_groups?
            return if Flipper.group_exists?(group_name)

            json_error_response(:group_not_registered)
          end

          def allow_unregistered_groups?
            allow_unregistered_groups = params['allow_unregistered_groups']
            allow_unregistered_groups && allow_unregistered_groups == 'true'
          end

          def disallow_unregistered_groups?
            !allow_unregistered_groups?
          end

          def group_name
            @group_name ||= params['name']
          end
        end
      end
    end
  end
end
