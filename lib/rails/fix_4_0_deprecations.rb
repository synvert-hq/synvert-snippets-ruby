# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'fix_4_0_deprecations' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It fixes rails 4.0 deprecations.

    ```ruby
    ActiveRecord::Fixtures
    ActiveRecord::TestCase
    ActionController::Integration
    ActionController::IntegrationTest
    ActionController::PerformanceTest
    ActionController::AbstractRequest
    ActionController::Request
    ActionController::AbstractResponse
    ActionController::Response
    ActionController::Routing
    ```

    =>

    ```ruby
    ActiveRecord::FixtureSet
    ActiveSupport::TestCase
    ActionDispatch::Integration
    ActionDispatch::IntegrationTest
    ActionDispatch::PerformanceTest
    ActionDispatch::Request
    ActionDispatch::Request
    ActionDispatch::Response
    ActionDispatch::Response
    ActionDispatch::Routing
    ```
  EOS

  if_gem 'rails', '>= 4.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    {
      'ActiveRecord::Fixtures' => 'ActiveRecord::FixtureSet',
      'ActiveRecord::TestCase' => 'ActiveSupport::TestCase',
      'ActionController::Integration' => 'ActionDispatch::Integration',
      'ActionController::IntegrationTest' => 'ActionDispatch::IntegrationTest',
      'ActionController::PerformanceTest' => 'ActionDispatch::PerformanceTest',
      'ActionController::AbstractRequest' => 'ActionDispatch::Request',
      'ActionController::Request' => 'ActionDispatch::Request',
      'ActionController::AbstractResponse' => 'ActionDispatch::Response',
      'ActionController::Response' => 'ActionDispatch::Response',
      'ActionController::Routing' => 'ActionDispatch::Routing'
    }.each do |deprecated, favor|
      with_node to_source: deprecated do
        replace_with favor
      end
    end
  end
end
