module Importable
  module DSL
    def importable(options = {}, &block)
      form do |f|
        f.semantic_errors # shows errors on :base
        f.inputs          # builds an input field for every attribute
        unless f.object.persisted?
          f.input :id, as: :hidden, input_html: { value: (f.object.class.maximum(:id).to_i + 1) }
        end
        f.actions
      end

      controller.const_set(:PAGE_OPTIONS, options)
      collection_action :import, method: :post do
        inserts, updates = if params[:dump][:bulk].to_i.nonzero?
                             Importable::Data.bulk(active_admin_config, params[:dump][:file], params[:dump])
                           else
                             Importable::Data.backup_save(active_admin_config, 'Auto backup', 'This backup file was auto generated during upload.', params[:dump][:file], params[:dump], &block)
        end
        redirect_to({ action: :index }, notice: "#{active_admin_config.resource_name} imported successfully! Rows created: #{inserts}. Rows updated: #{updates}.")
      end

      collection_action :backup, method: :get do
        rows = Importable::Data.backup(active_admin_config, 'snapshot', "Snapshot as of #{Time.now}")
        redirect_to({ action: :index }, notice: "#{rows} rows successfully backed up.")
      end

      collection_action :restore, method: :get do
        Importable::Data.backup(active_admin_config, 'backup', "Backup file created before restoring snapshot as of #{Time.now}")
        active_admin_config.resource_class.delete_all
        file = AdminBackup.find(params[:id]).file
        inserts, updates = Importable::Data.save(active_admin_config, file, { key: :id, retain: 1, 'file' => file }, &block)
        redirect_to({ action: :index }, notice: "#{active_admin_config.resource_name} restored successfully! #{inserts + updates} rows restored.")
      end

      sidebar 'Importer', partial: 'admin/uploader/uploader', only: :index, priority: 0
    end
  end
end
