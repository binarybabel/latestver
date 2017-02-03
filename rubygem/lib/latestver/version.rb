module Latestver
  begin
    require 'versioneer'
    VERSION = ::Versioneer::Config.new(::File.expand_path('../../../', __FILE__))
  rescue LoadError
    VERSION = '0.0.0'
  end
end
