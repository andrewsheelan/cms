class AdminBackup < ApplicationRecord
  mount_uploader :file, CSVUploader
end
