class CopyTableStaging < ApplicationRecord
  acts_as_copy_target
end

module Importable
  class Data
    UTF8 = 'UTF-8'.freeze
    def self.backup(active_admin_config, type = '', comments = '')
      target_model = active_admin_config.resource_class
      if target_model.respond_to? :copy_to_string
        file = target_model.copy_to_string
      else
        columns_hash = active_admin_config.resource_class.columns_hash
        attributes = columns_hash.keys
        file = CSV.generate(headers: true) do |csv|
          csv << attributes
          active_admin_config.resource_class.all.each do |res|
            csv << attributes.map do |attr|
              val = res.send(attr)
              val = val.to_json if columns_hash[attr].type == :jsonb
              val
            end
          end
        end
      end
      write_file(file, target_model, type, comments)
      active_admin_config.resource_class.count
    end

    def self.write_file(file_str, target_model, type, comments = '')
      newfile = FilelessIO.new(file_str)
      newfile.original_filename = "#{type}-#{target_model.name}-#{Time.now}.csv"
      AdminBackup.create(
        model: target_model.name,
        file: newfile,
        name: newfile.original_filename,
        comments: comments
      )
    end

    def self.backup_save(active_admin_config, type = '', comments = '', file_data, options, &block)
      backup(active_admin_config, type, comments)
      save(active_admin_config, file_data, options, &block)
    end

    def self.save(active_admin_config, file_data, options, &block)
      target_model = active_admin_config.resource_class
      file_data = file_data.read
      detection = CharlockHolmes::EncodingDetector.detect(file_data)
      content   = CharlockHolmes::Converter.convert file_data, detection[:encoding], UTF8

      ins       = upd = 0
      key       = options[:key] ? options[:key].to_sym : :id
      retain    = options[:retain]
      if options['file'].content_type =~ /json/
        rows = JSON.parse(content, header_converters: :symbol, encoding: UTF8)[active_admin_config.resource_table_name.delete('"')]
        json_mapping = active_admin_config.controller::PAGE_OPTIONS[:json_mapping]
        rows = rows.each_with_object([]) { |val, mapping| h = {}; val.each_with_index { |k, i| h[json_mapping[i]] = k }; mapping << h; } if json_mapping
        rows.each { |data| ins, upd = process_row(data, target_model, retain, key, ins, upd, &block) }
      else
        CSV.parse(content, headers: true, header_converters: :symbol, encoding: UTF8) do |row|
          data = row.to_hash
          ins, upd = process_row(data, target_model, retain, key, ins, upd, &block)
        end
      end
      reset_primary_keys(target_model)
      [ins, upd]
    end

    def self.bulk(active_admin_config, file_data, options)
      target_model = active_admin_config.resource_class
      before_counter = target_model.count
      write_file(target_model.copy_to_string, target_model, 'Auto Backup', 'Before Bulk upload')
      admin_backup = AdminBackup.create(
        model: target_model.name,
        file: file_data,
        name: "bulk-file-#{target_model.name}-#{Time.now}.csv",
        comments: 'Bulk upload backup'
      )
      file_path = if admin_backup.file._storage == CarrierWave::Storage::File
                    admin_backup.file.path
                  elsif admin_backup.file._storage == CarrierWave::Storage::Fog
                    admin_backup.file.url
                  else
                    admin_backup.file.path
      end
      table = target_model.table_name

      if options[:retain].to_i.zero?
        ActiveRecord::Base.connection.execute("TRUNCATE #{table} RESTART IDENTITY")
        target_model.copy_from(open(file_path))
      else
        table_column = options[:key] ? options[:key].to_sym : :id
        columns = target_model.columns.map(&:name)
        ActiveRecord::Base.connection.execute(ERB.new(
          File.read(Rails.root.join('lib/admin/importable/create.sql.erb'))
        ).result(binding))
        CopyTableStaging.copy_from(open(file_path))
        ActiveRecord::Base.connection.execute(ERB.new(
          File.read(Rails.root.join('lib/admin/importable/copy.sql.erb'))
        ).result(binding))
        ActiveRecord::Base.connection.execute(ERB.new(
          File.read(Rails.root.join('lib/admin/importable/drop.sql.erb'))
        ).result(binding))
      end
      reset_primary_keys(target_model)
      [(target_model.count - before_counter), 0]
    end

    private

    def self.reset_primary_keys(target_model)
      ActiveRecord::Base.connection.reset_pk_sequence!(target_model.table_name)
    rescue
      nil
    end

    def self.process_row(data, target_model, retain, key, ins, upd, &block)
      if data.present?
        if block_given?
          block.call(target_model, data)
        else
          if data[key]
            store = target_model.find_or_initialize_by(key => data[key])
            store.persisted? ? upd += 1 : ins += 1
            if retain.to_i.zero?
              data      = data.except(:id)
              data[:id] = (target_model.maximum(:id).to_i + 1) unless store.persisted?
            end
            store.update!(data)
          else
            target_model.create!(data)
            ins += 1
          end
        end
      end
      [ins, upd]
    end
  end
end
