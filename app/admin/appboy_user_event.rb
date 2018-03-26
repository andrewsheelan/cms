ActiveAdmin.register AppboyUserEvent do
  importable(key: 'id', retain: true, bulk: true)

  menu priority: 2
end
