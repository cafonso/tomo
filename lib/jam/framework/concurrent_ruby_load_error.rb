module Jam
  class Framework
    class ConcurrentRubyLoadError < Jam::Error
      attr_accessor :version

      def to_console
        <<~ERROR
          Running tasks on multiple hosts requires the #{yellow('concurrent-ruby')} gem.
          To install it, #{install_instructions}
        ERROR
      end

      private

      def install_instructions
        if Jam.bundled?
          gem_entry = %Q(gem "concurrent-ruby", "#{version}")
          "add this entry to your Gemfile:\n\n  #{blue(gem_entry)}"
        else
          gem_install = "gem install concurrent-ruby -v '#{version}'"
          "run:\n\n  #{blue(gem_install)}"
        end
      end
    end
  end
end