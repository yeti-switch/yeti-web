module ResourceDSL
  module ActsAsStat

    def has_member_action?(name)
      active_admin_config.member_actions.detect { |element| element.name == name.to_sym }.present?
    end

    def acts_as_stats_actions
      # must be used as last DSL for resource

      action_item :truncate_stats, only: [:show, :edit] do
        dropdown_menu 'Statistics' do

          if authorized?(:truncate_long_time_stats) && has_member_action?(:truncate_long_time_stats)
            item 'Truncate long time stats', action: :truncate_long_time_stats, id: resource.id
          end

          if authorized?(:truncate_short_window_stats) && has_member_action?(:truncate_short_window_stats)
            item 'Truncate short window stats', action: :truncate_short_window_stats, id: resource.id
          end

        end
      end

    end


    def acts_as_stat

      sidebar 'Long time stats', only: [:show, :edit] do
        if resource.statistic.nil?
          div do
            'No data'
          end
        else
          div class: :stats_table do
            attributes_table_for resource.statistic do
              row :created_at
              row :updated_at
              row :calls
              row :calls_success
              row :calls_fail
              row :total_duration
              row :asr
              row :acd
              row :locked_at
              row :unlocked_at
            end
          end
        end
      end

      member_action :truncate_long_time_stats do
        resource.statistic.try!(:destroy)
        flash[:notice] = "#{active_admin_config.resource_label}'s statistic was successfully truncated"
        redirect_back fallback_location: root_path
      end

    end

    def acts_as_quality_stat

      member_action :truncate_short_window_stats do
        resource.quality_stats.delete_all
        flash[:notice] = "#{active_admin_config.resource_label}'s statistic was successfully truncated"
        redirect_back fallback_location: root_path
      end

      sidebar 'Short window stats', only: [:show, :edit] do
        data = resource.quality_stats.total
        if data.count==0
          div do
            'No data'
          end
        else
          div class: :stats_table do
            attributes_table_for data do
              row :window do |t|
                strong do
                  text_node t.w
                  text_node ' h.'
                end
              end
              row :count do |t|
                strong do
                  text_node t.count
                end
              end
              row :short_count do |t|
                strong do
                  text_node t.short_count
                end
              end
              row :duration do |t|
                strong do
                  text_node t.duration
                  text_node ' min.'
                end
              end
              row :acd do |t|
                strong do
                  text_node t.acd
                  text_node ' min.'
                end
              end
              row :asr do |t|
                strong do
                  text_node t.asr
                end
              end
              row :max_pdd do |t|
                strong do
                  text_node t.max_pdd
                  text_node ' sec.'
                end
              end
              row :min_pdd do |t|
                strong do
                  text_node t.min_pdd
                  text_node ' sec.'
                end
              end
            end
          end
        end
      end



    end

  end
end
