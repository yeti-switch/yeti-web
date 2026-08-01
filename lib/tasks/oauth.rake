# frozen_string_literal: true

namespace :oauth do
  # Clients are registered in the admin UI (System → Admin Access → OAuth
  # Applications), not from here. What is left is the one thing the UI cannot
  # do: put a private key on the server's filesystem.
  namespace :oidc do
    # The id_token is signed with this key, so whoever can read it can mint an
    # identity for any admin on any client that trusts this issuer. Treat it
    # like the database password: 0400, deployed out of band, never in git.
    #
    # Rotation: publish the new key in JWKS before signing with it, keep the old
    # one published until every issued token has expired, then drop the old one.
    #
    # Usage:
    #   rake 'oauth:oidc:generate_signing_key[/etc/yeti-web/oidc_signing_key.pem]'
    desc 'Generate the RSA key that signs id_tokens'
    task :generate_signing_key, [:path] do |_t, args|
      path = args[:path].presence || 'config/oidc_signing_key.pem'
      raise ArgumentError, "refusing to overwrite existing key at #{path}" if File.exist?(path)

      key = OpenSSL::PKey::RSA.new(2048)
      File.write(path, key.to_pem)
      File.chmod(0o400, path)

      puts "Wrote a 2048-bit RSA private key to #{path} (mode 0400)."
      puts 'Point yeti_web.yml at it:'
      puts '  oauth:'
      puts '    oidc:'
      puts '      enabled: true'
      puts '      issuer: https://web.example.com'
      puts "      signing_key_path: #{path}"
    end
  end
end
