# frozen_string_literal: true

require 'optparse'

require 'ectoken'

module Ectoken
  class Cli
    attr_reader :argv

    def initialize(argv = ARGV)
      @argv = argv
    end

    def start!
      parse_options

      result = if options.decrypt
                 V3.decrypt(
                   key: options.key,
                   token: options.token,
                   verbose: options.verbose
                 )
               else
                 V3.encrypt(
                   key: options.key,
                   token: options.token,
                   verbose: options.verbose
                 )
               end
      puts result
    end

    protected

    attr_reader :options

    Options = Struct.new(
      :key,
      :token,
      :decrypt,
      :verbose
    )

    def parse_options
      # Create options, set defaults, then parse argv into options.
      @options = Options.new
      options.decrypt = false
      options.verbose = false
      OptionParser.new do |opts|
        opts.on('-kKEY', '--key=KEY', 'Token Key') do |o|
          options.key = o
        end

        opts.on('-tTOKEN', '--token=TOKEN', 'Token to encrypt or decrypt.') do |o|
          options.token = o
        end

        opts.on('-d', '--decrypt', 'Decrypt') do
          options.decrypt = true
        end

        opts.on('-v', '--verbose', 'Verbose output') do
          options.verbose = true
        end
      end.parse!(argv)
    end
  end
end
