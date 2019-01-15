# frozen_string_literal: true

Yeti::Application.config.app_build_info = begin
                                             YAML.load_file(File.join(Rails.root, 'version.yml'))
                                          rescue StandardError
                                            {}
                                           end
