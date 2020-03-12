require 'encryptor'
require 'securerandom'
  
  x = 0
  keys = []
  cipher = ''
  secret_key = ''
  iv = ''
  secure = []
  File.foreach(File.expand_path('config/.slacker', __dir__)) { |line| keys[x] = line.chomp; x += 1 }

  if File.exist? '/.slacker_keys'
    x = 0
    secure = []

    File.foreach('/.slacker_keys') { |line| secure[x] = line.chomp; x += 1 }
    cipher = secure[0]
    secret_key = secure[1] 
    iv = secure[2]
    
    Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secret_key, iv: iv)
    keys.map! { |key| decrypt key }
  else
    File.new('/.slacker_keys', 'w')
  end


def decrypt encrypted_value
  Encryptor.decrypt(value: encrypted_value)
end

def encrypt string
  Encryptor.encrypt(value: string)
end

p keys

cipher = OpenSSL::Cipher.new('aes-256-gcm')
# cipher.encrypt # Required before '#random_key' or '#random_iv' can be called. http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-encrypt
secret_key = SecureRandom.random_bytes(32) # Insures that the key is the correct length respective to the algorithm used.
iv = SecureRandom.random_bytes(16) # Insures that the IV is the correct length respective to the algorithm used.
secure[0] = cipher
secure[1] = secret_key
secure[2] = iv

Encryptor.default_options.merge!(algorithm: 'aes-256-cbc', key: secret_key, iv: iv)

File.write('/.slacker_keys', secure.join("\n"))

keys.map! do |key|
encrypt key
end
p keys
File.write((File.expand_path('config/.slacker', __dir__)), keys.join("\n"))
