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

      key = OpenSSL::PKey::RSA.new(2048)

      # Created at 0400 rather than written and then chmod'ed: File.write would
      # apply the process umask, typically leaving the key world-readable until
      # the next statement ran — a window another user on the host can read it
      # in. O_EXCL makes the refusal-to-overwrite atomic too, where a preceding
      # File.exist? check would be a TOCTOU.
      begin
        File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0o400) do |f|
          f.write(key.to_pem)
        end
      rescue Errno::EEXIST
        raise ArgumentError, "refusing to overwrite existing key at #{path}"
      end

      puts "Wrote a 2048-bit RSA private key to #{path} (mode 0400)."
      puts 'Point yeti_web.yml at it:'
      puts '  oauth:'
      puts '    enabled: true'
      puts '    issuer: https://web.example.com'
      puts '    oidc:'
      puts '      enabled: true'
      puts "      signing_key_path: #{path}"
    end
  end
end
