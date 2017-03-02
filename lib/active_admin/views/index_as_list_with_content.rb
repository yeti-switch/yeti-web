class ::ActiveAdmin::Views::IndexAsListWithContent < ActiveAdmin::Views::IndexAsTable

    def build(page_presenter, collection)

       #or put _foo.html.erb to views/admin/admin_users
       render partial: page_presenter[:partial]
       super
    end

    def self.index_name
      "list"
    end

end
