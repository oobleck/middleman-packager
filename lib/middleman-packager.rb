require "middleman-core"

require "middleman-packager/commands"

::Middleman::Extensions.register(:packager) do
  require "middleman-packager/extension"
  ::Middleman::Packager
end