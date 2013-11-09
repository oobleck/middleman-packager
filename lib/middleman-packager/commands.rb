require "middleman-core/cli"

require "middleman-packager/extension"
require "middleman-packager/pkg-info"

module Middleman
  module Cli

    # This class provides a "package" command for the middleman CLI.
    class Packager < Thor
      include Thor::Actions

      check_unknown_options!

      namespace :package

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      desc "package [options]", Middleman::Packager::TAGLINE
      method_option "build_before",
      :type => :boolean,
      :aliases => "-b",
      :desc => "Run `middleman build` before the package step"

      def package
        if options.has_key? "build_before"
          build_before = options.build_before
        else
          build_before = self.package_options.build_before
        end
        if build_before
          # http://forum.middlemanapp.com/t/problem-with-the-build-task-in-an-extension
          bundler = File.exist?('Gemfile')
          run("#{bundler ? 'bundle exec ' : ''}middleman build") || exit(1)
        end
        # app.after_build do |builder|
          send("package_run")
        # end
      end

      protected

      def print_usage_and_die(message)
        raise Error, "ERROR: " + message + "\n" + <<EOF
Error message goes here.
EOF
      end

      # def inst
      #   ::Middleman::Application.server.inst
      # end

      def package_run
        # app.after_build do |builder|
          cmd_mask = self.package_options.archive_cmd_mask
          file_mask = self.package_options.package_mask
          archive_source = self.package_options.archive_source
          timestamp = Time.now.to_i
          file_name = file_mask.gsub(/\{(ts|timestamp)\}/i, "#{timestamp}")
          command = cmd_mask.gsub(/\{cmd\}/, "#{cmd}").gsub(/\{from\}/, "#{archive_source}").gsub(/\{to\}/, "#{file_name}")
        #   builder.run "#{command}"
        # end
          run "#{command}"
      end

      def package_sftp
        require 'net/sftp'
        require 'ptools'

        host = self.package_options.host
        user = self.package_options.user
        pass = self.package_options.password
        path = self.package_options.path

        puts "## Packagering via sftp to #{user}@#{host}:#{path}"

        # `nil` is a valid value for user and/or pass.
        Net::SFTP.start(host, user, :password => pass) do |sftp|
          sftp.mkdir(path)
          Dir.chdir(self.inst.build_dir) do
            files = Dir.glob('**/*', File::FNM_DOTMATCH)
            files.reject { |a| a =~ Regexp.new('\.$') }.each do |f|
              if File.directory?(f)
                begin
                  sftp.mkdir("#{path}/#{f}")
                  puts "Created directory #{f}"
                rescue
                end
              else
                begin
                  sftp.upload(f, "#{path}/#{f}")
                rescue Exception => e
                  reply = e.message
                  err_code = reply[0,3].to_i
                  if err_code == 550
                    sftp.upload(f, "#{path}/#{f}")
                  end
                end
                puts "Copied #{f}"
              end
            end
          end
        end
      end

    end

    # Alias "d" to "package"
    Base.map({ "p" => "package" })

  end
end