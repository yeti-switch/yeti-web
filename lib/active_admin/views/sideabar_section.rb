# module ActiveAdmin
#   module Views
#
#     class SidebarSection < Panel
#       builder_method :sidebar_section
#
#
#       # def build(section)
#       #   @section = section
#       #   super(@section.title, icon: @section.icon)
#       #   self.id = @section.id
#       #   add_class(@section.options[:class])    if @section.options[:class]
#       #   build_sidebar_content
#       # end
#       def build(section)
#         @section = section
#         super(@section.title, {})
#         self.id = @section.id
#         add_class(@section.options[:class]) if @section.options[:class]
#         build_sidebar_content
#       end
#
#
#     end
#
#   end
# end
