module RedirectableFormBuilder
  def cancel_link(url = :back, html_options = {}, li_attrs = {})
    li_attrs[:class] ||= 'cancel'
    li_content = template.link_to I18n.t('active_admin.cancel'), url, html_options
    template.content_tag(:li, li_content, li_attrs)
  end
end

class ActiveAdmin::FormBuilder
  prepend RedirectableFormBuilder
end
