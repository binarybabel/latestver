require 'versioneer'

module Latestver
  RELEASE = '1.5'
  VERSION = Versioneer::Git.new(__FILE__,
                                :prereleases => %w(alpha beta),
                                :starting_release => self::RELEASE).to_s
end
