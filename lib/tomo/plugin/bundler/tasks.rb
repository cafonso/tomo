module Tomo::Plugin::Bundler
  class Tasks < Tomo::TaskLibrary
    def install
      return if remote.bundle?("check", *check_options) && !dry_run?

      remote.bundle("install", *install_options)
    end

    def clean
      remote.bundle("clean", settings[:bundler_clean_options])
    end

    def upgrade_bundler
      needed_bundler_ver = extract_bundler_ver_from_lockfile
      return if needed_bundler_ver.nil?

      remote.run(
        "gem", "install", "bundler",
        "--conservative", "--no-document",
        "-v", needed_bundler_ver
      )
    end

    private

    def check_options
      gemfile = settings[:bundler_gemfile]
      path = paths.bundler

      options = []
      options.push("--gemfile", gemfile) if gemfile
      options.push("--path", path) if path
      options
    end

    # rubocop:disable Metrics/AbcSize
    def install_options
      binstubs = settings[:bundler_binstubs]
      jobs = settings[:bundler_jobs]
      without = settings[:bundler_without]
      flags = settings[:bundler_flags]

      options = check_options.dup
      options.push("--binstubs", binstubs) if binstubs
      options.push("--jobs", jobs) if jobs
      options.push("--without", without) if without
      options.push(flags) if flags

      options
    end
    # rubocop:enable Metrics/AbcSize

    def extract_bundler_ver_from_lockfile
      lockfile_tail = remote.capture(
        "tail", "-n", "10", paths.release.join("Gemfile.lock"),
        raise_on_error: false
      )
      lockfile_tail[/BUNDLED WITH\n   (\S+)$/, 1]
    end
  end
end