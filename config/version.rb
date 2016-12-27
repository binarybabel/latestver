require 'versioneer'

module Latestver
  RELEASE = '1.6'
  begin
    VERSION = Versioneer::Git.new(__FILE__,
                                  :prereleases => %w(alpha beta),
                                  :starting_release => self::RELEASE).to_s
  rescue Versioneer::InvalidRepoError
    VERSION = self::RELEASE
  end
end
