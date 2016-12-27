if Rails.env.development?
  namespace :release do

    ### Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # File updated by [release:bump]
    version_file = 'config/version.rb'
    # How to determine current project version programmatically
    version_lambda = lambda { Object.const_get(Rails.application.class.name.sub(/::.+$/, ''))::RELEASE }
    # Default commit message (%s replaced by version)
    commit_message = 'Release %s'
    # Changelog file to read/write
    changelog_file = 'CHANGELOG.md'
    # List of shell commands to try to determine previously released commit hash...
    #   - the first non-empty command result is accepted
    #   - changelog will be built from this reference to current HEAD
    changelog_ref_sources = ['git describe --abbrev=0 --tags', 'git rev-list HEAD | tail -n 1']
    # Filter and format commit subjects for the changelog
    changelog_line_filter = lambda do |line|
      case line
        when /release|merge/i
          nil
        when /bug|fix/i
          '* __`!!!`__ ' + line
        when /add|support|ability/i
          '* __`NEW`__ ' + line
        when /remove|deprecate/i
          '* __`-!-`__ ' + line
        else
          '* __`~~~`__ ' + line
      end
    end

    ### Shortcuts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task :next => [:minor, :changelog] do
      puts "** Next steps to release #{version_lambda.call}"
      puts '1. %-35s # %s' % ["nano #{changelog_file}", 'Review']
      puts '2. %-35s # %s' % ['rake release:commit', 'Commit + Tag']
      puts '3. %-35s # %s' % ['git push --tags origin master', 'Publish']
    end
    task :prep do
      Rake::Task['release:bump'].invoke(2, 'pre')
      Rake::Task['release:commit'].invoke(false, 'Prepare for next release')
    end

    task(:major) { Rake::Task['release:bump'].invoke(1) }
    task(:minor) { Rake::Task['release:bump'].invoke(2) }
    task(:patch) { Rake::Task['release:bump'].invoke(3) }

    ### Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    desc 'Bump release to next version.'
    task :bump, [:version_length, :prerelease_suffix] => :environment do |t, args|
      args.with_defaults(:version_length => 3, :prerelease_suffix => nil)
      raise ArgumentError, 'Invalid bump version length.' if args[:version_length].to_s.empty?

      version = Gem::Version.new(version_lambda.call)
      length = args[:version_length].to_i
      (suffix = args[:prerelease_suffix]) and suffix << '1'

      if version.prerelease?
        if suffix.to_s.chop == version.segments[-2]
          suffix = suffix.chop + (version.segments[-1].to_i + 1).to_s
        end
        next_version = (version.release.segments + [suffix]).compact.join('.')
      else
        segments = version.release.segments.slice(0, length)
        while segments.size < length + 1 # Version.bump strips last segment
          segments << 0
        end
        next_version = [Gem::Version.new(segments.join('.')).bump.to_s, suffix].compact.join('.')
      end

      puts "** Version bump #{version} -> #{next_version}"
      system "sed -i '' 's/#{version}/#{next_version}/g' #{version_file}"
      system "git diff -U0 #{version_file}"
      Kernel.silence_warnings do
        load Rails.root.join(*version_file.split('/'))
      end
    end

    desc 'Generate changelog for current version (from last tagged release)'
    task :changelog => :environment do
      changelog_ref = ''
      changelog_ref_sources.each do |cmd|
        changelog_ref = %x{#{cmd} 2> /dev/null}.chomp
        break unless changelog_ref.empty?
      end
      raise 'Failed to determine base git reference for changelog.' if changelog_ref.empty?

      header = ''
      footer = ''
      if File.file?(changelog_file)
        File.open(changelog_file, 'r') do |f|
          in_header = true
          f.each_line do |line|
            if !in_header or line.match(/^##/)
              in_header = false
              footer << line
            else
              header << line
            end
          end
        end
      end

      current_version = version_lambda.call
      content = "### #{current_version} (#{DateTime.now.strftime('%Y-%m-%d')})\n\n"
      gitlog = %x{git log #{changelog_ref}...HEAD --pretty=format:'%s' --reverse}
      raise gitlog.to_s if $?.exitstatus > 0
      gitlog.chomp.split("\n").each do |line|
        line = changelog_line_filter.call(line.chomp)
        content << line + "\n" if line
      end
      content << "\n\n"

      puts "** Writing to #{changelog_file}"
      puts
      puts content
      File.write(changelog_file, header + content + footer)
    end

    desc 'Commit/tag current release'
    task :commit, [:tag, :message] do |t, args|
      puts '** Committing release'
      current_version = version_lambda.call
      files = [version_file, changelog_file].join(' ')
      args.with_defaults(:tag => true, :message => commit_message % [current_version])
      system "git reset > /dev/null && git add #{files}"
      system "git commit -m '#{args[:message]}'"
      if args[:tag] === true or args[:tag] == 'true'
        Rake::Task['release:tag'].invoke
      end
    end

    desc 'Tag current release'
    task :tag do
      puts '** Tagging release'
      current_version = version_lambda.call
      tag_mode = `[ -n "$(git config --local --get user.signingkey)" ] && echo "-s" || echo "-a"`.chomp
      system "git tag #{tag_mode} v#{current_version} -m ' #{commit_message % [current_version]}'"
      system 'git tag -n | head -n 1'
    end

    ### Rake Template Author + Updates ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #                                                                                             0101010
    #                                                                                          0010011
    #             _                                     _                                    110101
    #            | |                                   | |                                 0011
    #    _ __ ___| | ___  __ _ ___  ___       _ __ __ _| | _____                                    0100010
    #   | '__/ _ \ |/ _ \/ _` / __|/ _ \     | '__/ _` | |/ / _ \                      1010    0010101000001
    #   | | |  __/ |  __/ (_| \__ \  __/  _  | | | (_| |   <  __/                    010101110100111101010010
    #   |_|  \___|_|\___|\__,_|___/\___| (_) |_|  \__,_|_|\_\___|                   01     0011000100
    #                                                                   from
    #                                                                                 0100
    #                                                                              01001001
    #                                                                             0100111001    000001010001110
    #                                                                            101       0010010000010100100101
    #                                                                        00111          0010011110100011001010
    #                                                                        0110            10000010100111001000100
    #
    #                                                                                         github.com/binarybabel
    #
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  end
end
