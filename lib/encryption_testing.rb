# frozen_string_literal: true

require 'encryptor'
require 'securerandom'

x = 0
keys = []
secure = []
File.foreach(File.expand_path('config/.slacker', __dir__)) do |line|
  keys[x] = line.chomp
  x += 1
end

if File.exist? '/Users/.slacker_keys'
  x = 0
  secure = []

  File.foreach('/Users/.slacker_keys') do |line|
    secure[x] = line.chomp
    x += 1
  end

  Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secure[1],
                                   iv: secure[2])
  keys.map! { |key| decrypt key }
else
  File.new('/Users/.slacker_keys', 'w+')
end

def decrypt(encrypted_value)
  Encryptor.decrypt(value: encrypted_value)
end

def encrypt(string)
  Encryptor.encrypt(value: string)
end

p keys

# Insures that the key is the correct length respective to the algorithm used.
secret_key = SecureRandom.random_bytes(32)
# Insures that the IV is the correct length respective to the algorithm used.
iv = SecureRandom.random_bytes(16)
secure[1] = secret_key
secure[2] = iv

Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secret_key,
                                 iv: iv)

File.write('/Users/.slacker_keys', secure.join("\n"))

keys.map! do |key|
  encrypt key
end
p keys
File.write(File.expand_path('config/.slacker', __dir__), keys.join("\n"))
