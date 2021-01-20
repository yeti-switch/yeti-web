# frozen_string_literal: true

module ActiveAdmin::CredentialsHelper
  def generate_credential(length = 20)
    SecureRandom.alphanumeric(length)
  end
end
