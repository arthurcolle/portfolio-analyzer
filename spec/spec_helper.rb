# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|

  require 'simplecov'
  SimpleCov.start

  require 'webmock/rspec'
  WebMock.disable_net_connect!(allow_localhost: true)
  config.before(:each) do

    Sidekiq::Worker.clear_all  # Makes sure jobs don't linger between tests:

    # WebMock Reponse Setups #

    # Request for data feed symbology.
    stub_request(:get, 'https://api.iextrading.com/1.0/ref-data/symbols').
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.13.1'}).
      to_return(
        status: 200,
        body: '[{"symbol": "ABC", "name": "Acme Banana Company"}, {"symbol": "DEF", "name": "Default Energy Frostbite"}]',
        headers: {})
    # Request instrument prices for user.
    stub_request(:get, "https://api.iextrading.com/1.0/stock/market/batch?filter=companyName,latestPrice,change,latestUpdate&symbols=AAPL,AMZN,BABA,COF,FBGX,GOOG,GOOGL,GSK,HD,INTC,JNJ,SNY&types=quote").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.13.1'}).
      to_return(
        status: 200,
        body: '{"AAPL": {"quote": {"companyName": "Apple Inc.", "latestPrice": 170.15, "change": -0.95, "latestUpdate": 1510952400327}}}',
        headers: {})
    # Request for DJIA index value.
    stub_request(:get, 'https://www.alphavantage.co/query?apikey&function=TIME_SERIES_DAILY&symbol%5B%5D=DJIA').
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.13.1'}).
      to_return(status: 200,
        body: '{"Time Series (Daily)": {"2017-11-02": {"4. close": "23358.24"}, "2017-11-01": {"4. close":"23458.36"}}}',
        headers: {})
    # Request for Bloomberg headline news.
    stub_request(:get, 'https://newsapi.org/v1/articles?apikey&sortBy=top&source=bloomberg').
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.13.1'}).
      to_return(
        status: 200,
        body: '{
          "status": "ok",
          "articles": [{
            "source": {"id": "bloomberg", "name": "Bloomberg"},
            "author": "Shannon Pettypiece",
            "title": "Trump to Pay His Own Legal Bills, Set Up Fund to Cover Staff",
            "description": "President Donald Trump has started paying his own legal bills related to the Russia probe, rather than charging them to his campaign or the Republican National Committee, and is finalizing a plan to use personal funds to help current and former White House staff with their legal costs.",
            "url": "http://www.bloomberg.com/news/articles/2017-11-17/trump-to-pay-his-own-legal-bills-set-up-fund-to-cover-staff",
            "urlToImage": "https://assets.bwbx.io/images/users/iqjWHBFdfxIU/i5_F2CKD0NVI/v1/1200x675.jpg",
            "publishedAt": "2017-11-17T16:51:29Z"
          }]
        }',
        headers: {})
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end
