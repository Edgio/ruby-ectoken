# frozen_string_literal: true

require 'test_helper'

require 'ectoken'

class EctokenTest < Minitest::Test
  make_my_diffs_pretty! unless ENV['CI']
  parallelize_me!

  def test_encrypt
    key = 'testkey'
    token = 'sensitive=true&data=corgis_are_actually_bread'

    enc = Ectoken::V3.encrypt(key: key, token: token)
    refute_empty enc
  end

  def test_decrypt
    key = 'such-key-very-secret-wow'
    token = 'there is a large population of potatos'
    enc = Ectoken::V3.encrypt(key: key, token: token)

    assert_equal token, Ectoken::V3.decrypt(key: key, token: enc)
  end

  def test_decrypt_example
    example = 'a70LeQxZDBWQUHdzyhZak-QiyttbHjXVtBfVviqGHr96'
    key = 'beef'
    assert_equal 'steak', Ectoken::V3.decrypt(key: key, token: example)
  end

  def test_decode_token
    token = 'YWFhYWFhYWFhYWFhYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJiYmJjY2NjY2NjY2NjY2NjY2Nj'
    expected = {
      iv: 'a' * 12,
      ciphertext: 'b' * 32,
      tag: 'c' * 16
    }

    # send(:decode_token, token) because decode_token is protected on module
    # V3.
    assert_equal expected, Ectoken::V3.send(:decode_token, token)
  end
end
