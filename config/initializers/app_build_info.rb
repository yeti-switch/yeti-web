# frozen_string_literal: true

Rails.application.config.app_build_info = begin
                                             YAML.load_file(Rails.root.join('version.yml'))
                                          rescue StandardError
                                            {}
                                           end
