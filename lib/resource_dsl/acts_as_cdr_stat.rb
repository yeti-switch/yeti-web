# frozen_string_literal: true

module ResourceDSL
  module ActsAsCdrStat
    def acts_as_cdr_stat
      section = ActiveAdmin::SidebarSection.new 'Statistic', class: 'toggle', only: :index do
        div id: 'cdr_statistic', class: 'loader'
        div id: 'cdr_statistic_placeholder', class: 'cdr-stat-grid', style: 'display: none;' do
          div class: 'cdr-stat-cell cdr-stat-full' do
            span 'Originated calls', class: 'cdr-stat-label'
            strong id: :cdr_stat_originated_calls_count, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-cell' do
            span 'Terminated', class: 'cdr-stat-label'
            strong id: :cdr_stat_termination_attempts_count, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-cell' do
            span 'Rerouted', class: 'cdr-stat-label'
            strong id: :cdr_stat_rerouted_calls_count, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-separator'
          div class: 'cdr-stat-cell' do
            span 'Duration', class: 'cdr-stat-label'
            strong id: :cdr_stat_calls_duration, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-cell' do
            span 'ACD', class: 'cdr-stat-label'
            strong id: :cdr_stat_acd, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-cell' do
            span 'Orig ASR', class: 'cdr-stat-label'
            strong id: :cdr_stat_origination_asr, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-cell' do
            span 'Term ASR', class: 'cdr-stat-label'
            strong id: :cdr_stat_termination_asr, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-separator'
          div class: 'cdr-stat-cell cdr-stat-full' do
            span 'Profit', class: 'cdr-stat-label'
            strong id: :cdr_stat_profit, class: 'cdr-stat-value'
          end
          div class: 'cdr-stat-cell cdr-stat-full' do
            span 'Origination cost', class: 'cdr-stat-label'
            strong id: :cdr_stat_origination_cost, class: 'cdr-stat-value'
          end
          div id: :cdr_stat_origination_cost_by_currency, class: 'cdr-stat-by-currency'
          div class: 'cdr-stat-cell cdr-stat-full' do
            span 'Termination cost', class: 'cdr-stat-label'
            strong id: :cdr_stat_termination_cost, class: 'cdr-stat-value'
          end
          div id: :cdr_stat_termination_cost_by_currency, class: 'cdr-stat-by-currency'
        end
      end
      config.sidebar_sections.unshift section
    end
  end
end
