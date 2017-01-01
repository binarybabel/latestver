require 'versioneer'

module Latestver
  RELEASE = '1.6'
  begin
    VERSION = Versioneer::Config.new(File.expand_path('../../', __FILE__)).to_s
  rescue Versioneer::InvalidRepoError
    VERSION = self::RELEASE
  end
end
