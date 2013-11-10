Middleman Packager
------------------

This is a [Middleman](http://www.middlemanapp.com) extension to easily package up your build into a tgz, zip, or other file archiving mechanism.

This extension is inspired by the excellent [Middleman Deploy](https://github.com/tvaughan/middleman-deploy) extension.

## Requirements
[Middleman](http://www.middlemanapp.com) 3.0.0+

## Installation

Add this to your Middleman project's Gemfile

```ruby
gem "middleman-packager"
```
and run

```bash
$ bundle install
```

## Usage
Activate the extension in your `config.rb` file:

```ruby
activate :packager
```

```bash
$ middleman build [--clean]
$ middleman package [-b]
```

_-b_ : pre-build before packaging

### Config examples
###### Block config

```ruby
\# Use zip instead of tar+gzip
activate :packager do |pack|
    pack.package_mask = "build-{ts}.zip"
    pack.package_cmd_mask = "zip -r {to} {from}"
end
```

###### Inline config

```ruby
\# Custom filename mask
activate :packager,
    :package_mask => "../packages/my_project_{ts}.tgz"</code></pre>
```

## Options
Default options:

###### `:package_source`  _(default: [middleman build directory])_

The source file/folder of your package.

###### `:package_mask`  _(default: "build-{ts}.tgz")_

A filename mask to use as the target archive. Use {ts} for the generated timestamp. Accepts relative or absolute file paths, though relative is recommended!

###### `:package_cmd_mask`  _(default: "tar -zcf {to} {from}")_

The command and file sequence mask to use. This mask allows you to easily change your archiving tool if you don't want to use tar. _{to}_ is replaced with the compiled `:package_mask` value, and _{from}_ is replaced with the `:package_source` value. Just make sure you change the `:package_mask` option accordingly!

###### `:auto_package`  _(default: false)_

Should we auto-package after running a build?
_Note: This is not yet working_

###### `:pre_build`  _(default: false)_

Run a build before creating a package?
_Note: This is not yet working, though passing the `-b` parameter to the package command does work._

## ToDo

 - Get `:pre_build` working
 - Get `:auto_package` working
 - Cleanup gemspec to remove gemspec warnings
 - Make the {ts} replacement more robust. Time compatible.
 - Run this in `:build` mode rather than `:development` mode (mm-server)
     - Other `:development` extensions are running unneccessarily.
