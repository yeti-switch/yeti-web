class ActiveAdmin::Views::Pages::Base
  def build(*args)
    set_attribute :lang, I18n.locale
    build_active_admin_head
    build_page
    set_attribute "data-servertime", Time.current.strftime("%Y %m %d %H %M %S %Z")
  end
end
