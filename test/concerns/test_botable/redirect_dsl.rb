# This DSL gives a class level and an instance level way of calling specific test suite
#
# class AboutTest < ActionDispatch::IntegrationTest
#   redirect_test(from: '/about', to: '/new-about', user: User.first)
#
#   test 'a one-off action' do
#     redirect_action_test(from: '/about', to: '/new-about', user: User.first)
#   end
# end

module TestBotable
  module RedirectDsl
    extend ActiveSupport::Concern

    module ClassMethods

      def redirect_test(from:, to:, user: _test_bot_user(), label: nil, **options)
        options[:current_test] = label || "#{from} to #{to}"
        return if EffectiveTestBot.skip?(options[:current_test])

        method_name = test_bot_method_name('redirect_test', options[:current_test])

        define_method(method_name) { redirect_action_test(from: from, to: to, user: user, options: options) }
      end
    end

    # Instance Methods - Call me from within a test
    def redirect_action_test(from:, to:, user: _test_bot_user(), options: {})
      begin
        assign_test_bot_lets!(options.reverse_merge!(from: from, to: to, user: user))
      rescue => e
        raise "Error: #{e.message}.  Expected usage: redirect_action_test(from: '/about', to: '/new-about', user: User.first)"
      end

      self.send(:test_bot_redirect_test)
    end

  end
end
