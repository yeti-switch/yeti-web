# frozen_string_literal: true

namespace :oauth do
  namespace :oidc do
    # Usage:
    #   rake 'oauth:oidc:generate_signing_key[/etc/yeti-web/oidc_signing_key.pem]'
    desc 'Generate the RSA key that signs id_tokens'
    task :generate_signing_key, [:path] do |_t, args|
      path = args[:path].presence || 'config/oidc_signing_key.pem'

      key = OpenSSL::PKey::RSA.new(2048)

      # Created at 0400 rather than written then chmod'ed: File.write applies the
      # umask, leaving the key world-readable until the next statement. O_EXCL
      # makes the refusal-to-overwrite atomic instead of a TOCTOU.
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
