require "forwardable"

module Tomo
  class Remote
    extend Forwardable
    def_delegators :ssh, :close, :host
    def_delegators :shell_builder, :chdir, :env, :umask

    attr_reader :release

    def initialize(ssh, framework)
      @ssh = ssh
      @framework = framework
      @release = {}
      @shell_builder = ShellBuilder.new
      framework.helper_modules.each { |mod| extend(mod) }
      freeze
    end

    def attach(*command, default_chdir: nil, **command_opts)
      full_command = shell_builder.build(*command, default_chdir: default_chdir)
      ssh.ssh_exec(Script.new(full_command, **command_opts))
    end

    def run(*command, attach: false, default_chdir: nil, **command_opts)
      attach(*command, default_chdir: default_chdir, **command_opts) if attach

      full_command = shell_builder.build(*command, default_chdir: default_chdir)
      ssh.ssh_subprocess(Script.new(full_command, **command_opts))
    end

    private

    def_delegators :framework, :paths, :settings
    attr_reader :framework, :ssh, :shell_builder

    def logger
      Tomo.logger
    end

    def remote
      self
    end
  end
end