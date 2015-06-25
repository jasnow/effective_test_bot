module EffectiveTestBotTestHelper

  # This makes sure capybara is done, and breaks out of any 'within' blocks
  def synchronize!
    page.document.find('html')
  end

  # Because capybara-webkit can't make delete requests, we need to use rack_test
  # Makes a DELETE request to the given path as the given user
  # It leaves any existing Capybara sessions untouched
  def visit_delete(path, user)
    session = Capybara::Session.new(:rack_test, Rails.application)
    sign_in(user)
    session.driver.submit :delete, path, {}
    session.document.find('html')
  end

  # EffectiveTestBot includes an after_filter on ApplicationController to set an http header
  # that encodes the flash message, and some of the assigns
  def flash
    @flash ||= (
      header = page.driver.browser.response_headers['Flash']
      header.present? ? (JSON.parse(Base64.decode64(header)) rescue {}) : {}
    )
  end

end
