class AddDescriptionToSchedulers < ActiveRecord::Migration[5.1]
  def change
    add_column :schedulers, :description, :string
  end
end
