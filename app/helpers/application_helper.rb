# frozen_string_literal: true

module ApplicationHelper
  def form_title(title = nil)
    verb = case params[:action]
           when 'create'
             'new'
           when 'update'
             'edit'
           else
             params[:action]
           end
    I18n.t("active_admin.#{verb}_model", model: (title || active_admin_config.resource_label))
  end

  def whodunit_link(who)
    who = whodunit(who)

    if who.is_a?(AdminUser)
      link_to who.username, admin_user_path(who)
    else
      who || 'Unknown!'
    end
  end

  def whodunit(who)
    id = who.to_i
    if id > 0
      begin
        AdminUser.find(id)
      rescue StandardError
        who
      end
    else
      who
    end
  end

  def remote_chosen_request(type, path, params, target_selector, prompt = 'Select an Option')
    target_selector = "$('##{target_selector}')" if target_selector.is_a?(Symbol)

    "
      var el = this;
      $.#{type}(
          '#{path}',
          { #{params.collect { |p| "#{p[0]}: #{p[1]}" }.join(', ')} },
          function(data) {
            var target = $(#{target_selector}),
                prompt = '#{prompt}';
            if ( target.is( 'select' ) ) {
              var options_html = '';
              if ( prompt ) {
                options_html += '<option value=\"\">' + prompt + '</option>';
              }
              options_html += data;
              target.html(options_html);
            } else {
              target.val(data);
            }
            #{target_selector}.trigger('chosen:updated');
          }
      );
      "
  end

  def delayed_remote_chosen_request(delay_ms, type, path, params, target_selector, prompt = 'Select an Option')
    target_selector = "$('##{target_selector}')" if target_selector.is_a?(Symbol)

    "
      var el = this;
      delay(function(){
        $.#{type}(
            '#{path}',
            { #{params.collect { |p| "#{p[0]}: #{p[1]}" }.join(', ')} },
            function(data) {
                #{target_selector}.html('<option value=\"\">#{prompt}</option>'+ data);
                #{target_selector}.trigger('chosen:updated');
            }
        );
      }, #{delay_ms});
    "
  end
end
