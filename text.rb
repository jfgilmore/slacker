require 'encryptor'
require 'securerandom'

def decrypt encrypted_value
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  # cipher.encrypt # Required before '#random_key' or '#random_iv' can be called. http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-encrypt
  secret_key = SecureRandom.random_bytes(32) # Insures that the key is the correct length respective to the algorithm used.
  iv = SecureRandom.random_bytes(16) # Insures that the IV is the correct length respective to the algorithm used.
  # salt = SecureRandom.random_bytes(16)

  Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secret_key, iv: iv)
  decrypted_value = Encryptor.decrypt(value: encrypted_value)
  decrypted_value
end

def encrypt string
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  # cipher.encrypt # Required before '#random_key' or '#random_iv' can be called. http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-encrypt
  secret_key = SecureRandom.random_bytes(32) # Insures that the key is the correct length respective to the algorithm used.
  iv = SecureRandom.random_bytes(16) # Insures that the IV is the correct length respective to the algorithm used.
  # salt = SecureRandom.random_bytes(16)
  
  Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secret_key, iv: iv)
  encrypted_value = Encryptor.encrypt(value: string)
  encrypted_value
end

string = "hello, world"
string = encrypt string
puts string

string = decrypt string
puts string
