module Locomotive
  module Mounter
    module Models

      class ContentType < Base

        ## fields ##
        field :name
        field :description
        field :slug
        field :label_field_name
        field :group_by_name
        field :order_by
        field :order_direction
        field :public_submission_enabled
        field :public_submission_accounts

        field :fields, type: :array, class_name: 'Locomotive::Mounter::Models::ContentField'

      end

    end
  end
end