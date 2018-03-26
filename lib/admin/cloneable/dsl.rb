module Cloneable
  module DSL
    def cloneable
      member_action :clone, method: :get do
        resource = active_admin_config.resource_class.find(params[:id])
        q = resource.dup.attributes.to_query(
          active_admin_config.resource_name.element
        )
        redirect_to("#{active_admin_config.route_collection_path}/new?#{q}")
      end

      batch_action 'Clone' do |ids|
        if ids.count > 1
          @items = active_admin_config.resource_class.find(ids)
          begin
            @items.map(&:dup).map(&:save!)
          rescue => e
            flash[:error] = e.message
          end
          redirect_to active_admin_config.route_collection_path
        else
          resource = active_admin_config.resource_class.find(ids.first)
          redirect_to(edit_resource_path(resource).gsub(/edit/, 'clone'))
        end
      end
    end
  end
end

# Monkey patch for default actions.
module ActiveAdmin
  module Views
    class IndexAsTable < ActiveAdmin::Component
      def actions(options = {}, &block)
        name = options.delete(:name) { '' }
        defaults      = options.delete(:defaults) { true }
        dropdown      = options.delete(:dropdown) { false }
        dropdown_name = options.delete(:dropdown_name) { I18n.t 'active_admin.dropdown_actions.button_label', default: 'Actions' }

        options[:class] ||= 'col-actions'

        column name, options do |resource|
          if dropdown
            dropdown_menu dropdown_name do
              defaults(resource) if defaults
              instance_exec(resource, &block) if block_given?
            end
          else
            table_actions do
              defaults(resource, css_class: :member_link) if defaults
              if block_given?
                block_result = instance_exec(resource, &block)
                text_node block_result unless block_result.is_a? Arbre::Element
              end
            end
          end
        end
      end

      private

      def defaults(resource, options = {})
        if controller.action_methods.include?('show') && authorized?(ActiveAdmin::Auth::READ, resource)
          item I18n.t('active_admin.view'), resource_path(resource), class: "view_link #{options[:css_class]}", title: I18n.t('active_admin.view')
        end
        if controller.action_methods.include?('clone') && authorized?(ActiveAdmin::Auth::CREATE, resource)
          item 'Clone', edit_resource_path(resource).gsub(/edit/, 'clone'), class: "edit_link #{options[:css_class]}", title: 'Clone'
        end
        if controller.action_methods.include?('edit') && authorized?(ActiveAdmin::Auth::UPDATE, resource)
          item I18n.t('active_admin.edit'), edit_resource_path(resource), class: "edit_link #{options[:css_class]}", title: I18n.t('active_admin.edit')
        end
        if controller.action_methods.include?('destroy') && authorized?(ActiveAdmin::Auth::DESTROY, resource)
          item I18n.t('active_admin.delete'), resource_path(resource), class: "delete_link #{options[:css_class]}", title: I18n.t('active_admin.delete'),
                                                                       method: :delete, data: { confirm: I18n.t('active_admin.delete_confirmation') }
        end
      end
    end
  end
end
