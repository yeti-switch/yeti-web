# frozen_string_literal: true

Rails.application.config.app_build_info = begin
                                             YAML.load_file(File.join(Rails.root, 'version.yml'))
                                          rescue StandardError
                                            {}
                                           end
