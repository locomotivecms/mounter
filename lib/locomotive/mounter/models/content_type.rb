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

        field :fields,  type: :array, class_name: 'Locomotive::Mounter::Models::ContentField'

        field :entries, association: true

        ## methods ##

        def label_field_name
          self.fields.first.name
        end

        def find_field(name)
          self.fields.detect { |field| field.name.to_s == name.to_s }
        end

        def find_entry(id)
          self.entries.detect { |entry| [entry._permalink, entry._label].include?(id) }
        end

        def find_entries_among(ids)
          self.entries.find_all { |entry| [*ids].any? { |v| [entry._permalink, entry._label].include?(v) } }
        end

        def find_entries_by(name, id)
          self.entries.find_all { |entry| [*id].include?(entry.send(name.to_sym)) }
        end

      end

    end
  end
end