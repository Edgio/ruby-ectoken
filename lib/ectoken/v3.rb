# frozen_string_literal: true

require 'ectoken'

require 'digest/sha2'
require 'securerandom'
require 'openssl'
require 'base64'

module Ectoken
  module V3
    class << self
      # Decrypt an ectoken
      def decrypt(key:, token:, verbose: false)
        key_hash = Digest::SHA256.digest(key)
        decoded = decode_token(token)

        cipher = OpenSSL::Cipher.new('aes-256-gcm').decrypt.tap do |c|
          c.key = key_hash
          c.iv = decoded[:iv]
          c.auth_tag = decoded[:tag]
        end

        if verbose
          puts
          puts "+#{'-' * 79}"
          puts '| decrypt():'
          puts "| iv: #{decoded[:iv].inspect} (#{decoded[:iv].length})"
          puts "| tag: #{decoded[:tag].inspect} (#{decoded[:tag].length})"
          puts "| key: #{key_hash.inspect} (#{key_hash.length})"
          puts "| ciphertext: #{decoded[:ciphertext].inspect}"
          puts "+#{'-' * 79}"
          puts
        end

        cipher.update(decoded[:ciphertext]) + cipher.final
      end

      # Encrypt an ectoken
      def encrypt(key:, token:, verbose: false)
        key_hash = Digest::SHA256.digest(key)
        iv = SecureRandom.random_bytes(12)

        if verbose
          puts
          puts "+#{'-' * 79}"
          puts '| encrypt():'
          puts "| iv: #{iv}"
          puts "| key: #{key_hash}"
          puts "| plaintext: #{token}"
          puts "+#{'-' * 79}"
          puts
        end

        cipher = OpenSSL::Cipher.new('aes-256-gcm').encrypt
        cipher.iv = iv
        cipher.padding = 0
        cipher.key = key_hash

        enc = iv + cipher.update(token) + cipher.final + cipher.auth_tag
        Base64.urlsafe_encode64(enc)
      end

      protected

      def decode_token(token)
        decoded = Base64.urlsafe_decode64(token)
        {
          iv: decoded[0..11],
          tag: decoded[-16..],
          ciphertext: decoded[12..-17]
        }
      end
    end
  end
end
