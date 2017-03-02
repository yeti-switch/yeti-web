module ResourceDSL

  module ActsAsCdrStat
    def acts_as_cdr_stat
      section = ActiveAdmin::SidebarSection.new 'Statistic', class: 'toggle', only: :index do
        div id: "cdr_statistic", class: "loader"
        ul id: "cdr_statistic_placeholder", style: "display: none;" do
          li do
            span "Originated calls:"
            strong id: :cdr_stat_originated_calls_count
          end
          li do
            span "Rerouted calls:"
            strong id: :cdr_stat_rerouted_calls_count
          end
          li do
            span "Termination attempts:"
            strong id: :cdr_stat_termination_attempts_count
          end

          li do
            span "Total duration:"
            strong id: :cdr_stat_calls_duration
          end
          li do
            span "ACD:"
            strong id: :cdr_stat_acd
          end
          li do
            span "Origination ASR:"
            strong id: :cdr_stat_origination_asr
          end
          li do
            span "Termination ASR:"
            strong id: :cdr_stat_termination_asr
          end
          li do
            span "Profit:"
            strong id: :cdr_stat_profit
          end
          li do
            span "Origination cost:"
            strong id: :cdr_stat_origination_cost
          end
          li do
            span "Termination cost:"
            strong id: :cdr_stat_termination_cost
          end

        end
      end
      config.sidebar_sections.unshift section
    end
  end
end