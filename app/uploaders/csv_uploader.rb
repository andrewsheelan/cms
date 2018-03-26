# encoding: utf-8

class CSVUploader < CarrierWave::Uploader::Base
  def extension_whitelist
    [:csv]
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
