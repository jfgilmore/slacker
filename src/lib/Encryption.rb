# frozen_string_literal: true

# The Encryption class handles all of the encryption and decryption of secret keys and tokens.
# Idealy this service would be hosted remotely so the encryption and decryption keys are not accessible to an attaker.
#
class Encryption
  require 'encryptor'
  require 'securerandom'
  require 'yaml'

  def initialize
    x = 0
    cipher = ''
    secret_key = ''
    iv = ''
    keys = YAML.load_file(File.expand_path('config/.slacker.yml', __dir__))

    if File.exist?(ENV['HOME'] + '/.slacker_keys.yml')
      x = 0

      secure = YAML.load_file(ENV['HOME'] + '/.slacker_keys.yml')
      cipher = secure[:cipher]
      secret_key = secure[:key]
      iv = secure[:iv]

      Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secret_key, iv: iv)
      keys.each_pair { |key, value| keys[key] = decrypt value }
    else
      YAML.load_file(File.new(ENV['HOME'] + '/.slacker_keys.yml', 'w+'))
    end

    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    # cipher.encrypt # Required before '#random_key' or '#random_iv' can be called. http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-encrypt

    secret_key = SecureRandom.random_bytes(32) # Insures that the key is the correct length respective to the algorithm used.
    iv = SecureRandom.random_bytes(16) # Insures that the IV is the correct length respective to the algorithm used.
    secure = { cipher: cipher,
               key: secret_key,
               iv: iv }

    Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secret_key, iv: iv)

    File.write(ENV['HOME'] + '/.slacker_keys.yml', secure.to_yaml)

    keys.each_pair do |key, value|
      p value
      keys[key] = encrypt value

      File.write(File.expand_path('config/.slacker.yml', __dir__), keys.to_yaml)
    end
  end

  def decrypt(encrypted_value)
    Encryptor.decrypt(value: encrypted_value)
  end

  def encrypt(string)
    Encryptor.encrypt(value: string)
  end
end
