# frozen_string_literal: true

require 'logger'

module TestContext
  module_function

  def root_path
    @root_path ||= Pathname.new File.expand_path('../../', __dir__)
  end

  def logger
    @logger ||= Logger.new root_path.join('log/test.log')
  end
end
