ActiveAdmin.register AdminBackup do
  menu :parent => 'Admin'
  importable({key: 'name', retain: true})
end
