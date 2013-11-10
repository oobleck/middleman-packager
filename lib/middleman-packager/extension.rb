# Require core library
require "middleman-core"

# Extension namespace
module Middleman
  module Packager

    class PkgOptions < Struct.new(:package_source, :package_mask, :package_cmd_mask, :auto_package, :pre_build); end

    class << self

      def pkgopts
        @@pkgopts
      end

      def registered(app, options_hash={}, &block)
        # Default options for the rsync method.
        defaults = {
            :package_source => app.config[:build_dir],
            :package_mask => "package-{ts}.tgz",
            :package_cmd_mask => "tar -zcf {to} {from}",
            :pre_build => false,
            :auto_package => false
        }
        # TODO: Refactor this with merge!
        opts = defaults.merge(options_hash)
        # opts = PkgOptions.new(options_hash)
        # yield opts if block_given?

        @@pkgopts = opts

        app.send :include, Helpers
      end

      alias :included :registered

    end

    module Helpers
      def pkgopts
        ::Middleman::Packager.pkgopts
      end
    end

  end
end