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
      method_option "pre_build",
        :type => :boolean,
        :aliases => "-b",
        :desc => "Run `middleman build` before the package step"

      def package
        if options.has_key? "pre_build"
          pre_build = options.pre_build
        else
          pre_build = self.options.pre_build
        end
        if pre_build
          # http://forum.middlemanapp.com/t/problem-with-the-build-task-in-an-extension
          bundler = File.exist?('Gemfile')
          run("#{bundler ? 'bundle exec ' : ''}middleman build") || exit(1)
        end
        puts "cmd: pre_build? #{pre_build}"
        if options.auto_package
          app.after_build do |builder|
            send("package_run")
          end
        else
        end
          send("package_run")
      end

      protected

      def print_usage_and_die(message)
        raise Error, "\nERROR: " + message + "\n" + <<EOF
  [Default settings]
  activate #{:packager.inspect} do |conf|
    conf.package_source = config[:build_dir]
    conf.package_mask = "build-{ts}.tgz"
    conf.package_cmd_mask = "tar -zcf {to} {from}"
    conf.auto_package = false
    conf.pre_build = false
  end
EOF
      end # of print_usage_and_dir

      def inst
        ::Middleman::Application.server.inst
      end

      def opts
        opts = nil

        begin
          opts = inst.pkgopts || {}
        rescue NoMethodError
          print_usage_and_die "You need to activate the #{:packager.inspect} extension in config.rb."
        end

        if (!opts[:package_source])
          print_usage_and_die "The package extension requires you to set a source file or directory."
        end

        opts
      end

      def package_run
          timestamp = Time.now.to_i
          file_name = (self.opts[:package_mask]).gsub(/\{(ts|timestamp)\}/i, "#{timestamp}")
          command = (self.opts[:package_cmd_mask])
                      .gsub(/\{from\}/, "#{self.opts[:package_source]}")
                      .gsub(/\{to\}/, "#{file_name}")
          run("#{command}")
      end

    end

    Base.map({ "pack" => "package" })

  end
end