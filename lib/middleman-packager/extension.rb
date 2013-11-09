# Require core library
require "middleman-core"

# Extension namespace
module Middleman
  module Packager

    class Options < Struct.new(:package_source, :package_mask, :package_cmd_mask, :build_before); end

    class << self

      def options
        @@options
      end

      def registered(app, options_hash={}, &block)
        options = Options.new(options_hash)
        yield options if block_given?

        # Default options for the rsync method.
        options.package_source ||= config[:build_dir]
        options.package_mask ||= "package-{ts}.tgz"
        options.package_cmd_mask ||= "tar -zcf {to} {from}"
        options.build_before ||= false

        # Legacy options for Deploy
        options.port ||= 22
        options.clean ||= false

        # Default options for the git method.
        options.remote ||= "origin"
        options.branch ||= "gh-pages"


        @@options = options

        app.send :include, Helpers
      end

      alias :included :registered

    end

    module Helpers
      def options
        ::Middleman::Packager.options
      end
    end

  end
end