#= require active_admin/base
#= require activeadmin_addons/all
#= require select2
$ ->
  $('select').select2({ width: 'resolve' })
  $('#footer').appendTo('body')
  $('head').append("<link href='/assets/images/favicon.ico' rel='shortcut icon'>");
