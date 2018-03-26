module Versionable
  module DSL
    def versionable
      controller do
        def show
          @item = active_admin_config.resource_class.includes(versions: :item).find(params[:id])
          @versions = @item.versions
        end
      end

      collection_action :show_history, :method => :get do
        @item = active_admin_config.resource_class.find(params[:id])
        @versions = @item.versions
        render "admin/history/history"
      end

      batch_action 'histories' do |ids|
        @items = active_admin_config.resource_class.find(ids)
        @versions = @items.collect(&:versions).flatten
        render "admin/history/history"
      end

      sidebar :changes, :partial => "admin/version/version", only: :show
    end
  end
end
