class CreateAdminBackups < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_backups do |t|
      t.string :name
      t.string :model
      t.string :file
      t.string :comments

      t.timestamps
    end
  end
end
