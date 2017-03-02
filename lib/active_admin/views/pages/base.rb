class ActiveAdmin::Views::Pages::Base
  def build
    super
    add_classes_to_body
    build_active_admin_head
    build_page
    @body.set_attribute "data-servertime", Time.current.strftime("%Y %m %d %H %M %S %Z")
  end
end
