# This DSL gives a class level and an instance level way of calling specific test suite
#
# class PostsTest < ActionDispatch::IntegrationTest
#   member_test('admin/jobs', 'unarchive', User.first, Post.first)
#
#   test 'a one-off action' do
#     member_action_test('admin/jobs', 'unarchive', User.first)
#   end
# end

# A member_test assumes assumes route.name.present? && route.verb.to_s.include?('GET') && route.path.required_names == ['id']
# we HAVE TO build or have available one of these resources so we can pass the ID to it and see what happens :)

module TestBotable
  module WizardDsl
    extend ActiveSupport::Concern

    module ClassMethods

      def wizard_test(from_path, to_path, user, options = {})
        options[:current_test] = "#{from_path} to #{to_path}"
        method_name = test_bot_method_name('wizard_test', options.delete(:label) || options[:current_test])

        define_method(method_name) { wizard_action_test(from_path, to_path, user, options) }
      end

    end

    # Instance Methods - Call me from within a test
    def wizard_action_test(from_path, to_path, user, options = {})
      begin
        assign_test_bot_lets!(options.reverse_merge!(from_path: from_path, to_path: to_path, user: user))
      rescue => e
        raise "Error: #{e.message}.  Expected usage: wizard_action_test('/fee_wizard/step1', '/fee_wizard/step5', User.first)"
      end

      self.send(:test_bot_wizard_test)
    end

  end
end