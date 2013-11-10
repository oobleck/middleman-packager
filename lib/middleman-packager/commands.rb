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
        # puts "package running"
        if options.has_key? "build_before"
          build_before = options.build_before
        else
          build_before = self.options.build_before
        end
        if build_before
          # http://forum.middlemanapp.com/t/problem-with-the-build-task-in-an-extension
          bundler = File.exist?('Gemfile')
          run("#{bundler ? 'bundle exec ' : ''}middleman build") || exit(1)
        end
        send("package_run")
      end

      protected

      def print_usage_and_die(message)
        # raise Error, "\nERROR: " + message + "\n" + <<EOF\n EOF
        raise Error, "\nERROR: " + message + "\n"
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
        # http://www.ruby-doc.org/core-2.0.0/Time.html#method-i-strftime
        opts = self.opts
        time = Time.now()
        timestamp = time.to_i
        if opts[:package_mask].match(/{(ts|timestamp):.+}/)
          format = (opts[:package_mask].match(/{(ts|timestamp):(?<format>.+)}/))[:format]
          timestamp = time.strftime(format)
        end
        file_name = (opts[:package_mask]).gsub(/{(ts|timestamp):?.*}/i, "#{timestamp}")
        command = (opts[:package_cmd_mask])
                    .gsub(/\{from\}/, "#{opts[:package_source]}")
                    .gsub(/\{to\}/, "#{file_name}")
        run(command)
        if ($?.success?)
          # puts "== Your build package is: #{file_name}"
        else
          print_usage_and_die "There was a problem creating your build package. Please check your configuration."
        end
      end

    end

    Base.map({
      "pack" => "package",
      "zip" => "package",
      "archive" => "package"
    })

  end
end