# frozen_string_literal: true

Synvert::Rewriter.new 'faker', 'use_keyword_arguments' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It replaces positional arguments with keyword arguments, e.g.

    ```ruby
    Faker::Lorem.sentence(20)
    Faker::Date.between(1.year.ago, 1.month.ago)
    ```

    =>

    ```ruby
    Faker::Lorem.sentence(word_count: 20)
    Faker::Date.between(from: 1.year.ago, to: 1.month.ago)
    ```
  EOS

  if_gem 'faker', '>= 2.0'

  FAKER_USE_KEYWORD_ARGUMENTS_MAPPING = {
    'Faker::Books::Dune' => {
      'quote' => [['character']],
      'saying' => [['source']]
    },
    'Faker::Books::Lovecraft' => {
      'fhtagn' => [['number']],
      'paragraph' => [['sentence_count'], ['sentence_count', 'random_sentences_to_add']],
      'paragraph_by_chars' => [['characters']],
      'paragraphs' => [['number']],
      'sentence' => [['word_count'], ['word_count', 'random_words_to_add']],
      'sentences' => [['number']],
      'words' => [['number'], ['number', 'spaces_allowed']]
    },
    'Faker::Address' => {
      'city' => [['options']],
      'postcode' => [['state_abbreviation']],
      'street_address' => [['include_secondary']],
      'zip' => [['state_abbreviation']],
      'zip_code' => [['state_abbreviation']]
    },
    'Faker::Alphanumeric' => {
      'alpha' => [['number']],
      'alphanumeric' => [['number']]
    },
    'Faker::Avatar' => {
      'image' => [
        ['slug'],
        ['slug', 'size'],
        ['slug', 'size', 'format'],
        ['slug', 'size', 'format', 'set'],
        ['slug', 'size', 'format', 'set', 'bgset']
      ]
    },
    'Faker::Bank' => {
      'account_number' => [['digits']],
      'iban' => [['country_code']]
    },
    'Faker::ChileRut' => {
      'full_rut' => [['min_rut'], ['min_rut', 'fixed']],
      'rut' => [['min_rut'], ['min_rut', 'fixed']]
    },
    'Faker::Code' => {
      'ean' => [['base']],
      'isbn' => [['base']],
      'nric' => [['min_age'], ['min_age', 'max_age']]
    },
    'Faker::Commerce' => {
      'department' => [['max'], ['max', 'fixed_amount']],
      'price' => [['range'], ['range', 'as_string']],
      'promotion_code' => [['digits']]
    },
    'Faker::Company' => {
      'polish_register_of_national_economy' => [['length']]
    },
    'Faker::CryptoCoin' => {
      'acronym' => [['coin']],
      'coin_name' => [['coin']],
      'url_logo' => [['coin']]
    },
    'Faker::Date' => {
      'backward' => [['days']],
      'between' => [['from', 'to']],
      'between_except' => [['from', 'to', 'excepted']],
      'birthday' => [['min_age'], ['min_age', 'max_age']],
      'forward' => [['days']]
    },
    'Faker::Demographic' => {
      'height' => [['unit']]
    },
    'Faker::File' => {
      'dir' => [['segment_count'], ['segment_count', 'root'], ['segment_count', 'root', 'directory_separator']],
      'file_name' => [['dir'], ['dir', 'name'], ['dir', 'name', 'ext'], ['dir', 'name', 'ext', 'directory_separator']]
    },
    'Faker::Fillmurray' => {
      'image' => [['grayscale'], ['grayscale', 'width'], ['grayscale', 'width', 'height']]
    },
    'Faker::Finance' => {
      'vat_number' => [['country']]
    },
    'Faker::Hipster' => {
      'paragraph' => [
        ['sentence_count'],
        ['sentence_count', 'supplemental'],
        ['sentence_count', 'supplemental', 'random_sentences_to_add']
      ],
      'paragraph_by_chars' => [['characters'], ['characters', 'supplemental']],
      'paragraphs' => [['number'], ['number', 'supplemental']],
      'sentence' => [
        ['word_count'],
        ['word_count', 'supplemental'],
        ['word_count', 'supplemental', 'random_words_to_add']
      ],
      'sentences' => [['number'], ['number', 'supplemental']],
      'words' => [['number'], ['number', 'supplemental'], ['number', 'supplemental', 'spaces_allowed']]
    },
    'Faker::Internet' => {
      'domain_name' => [['subdomain']],
      'email' => [['name'], ['name', 'separators']],
      'fix_umlauts' => [['string']],
      'free_email' => [['name']],
      'mac_address' => [['prefix']],
      'password' => [
        ['min_length'],
        ['min_length', 'max_length'],
        ['min_length', 'max_length', 'mix_case'],
        ['min_length', 'max_length', 'mix_case', 'special_characters']
      ],
      'safe_email' => [['name']],
      'slug' => [['words'], ['words', 'glue']],
      'url' => [['host'], ['host', 'path'], ['host', 'path', 'scheme']],
      'user_agent' => [['vendor']],
      'user_name' => [['specifier'], ['specifier', 'separators']],
      'username' => [['specifier'], ['specifier', 'separators']]
    },
    'Faker::Invoice' => {
      'amount_between' => [['from'], ['from', 'to']],
      'creditor_reference' => [['ref']],
      'reference' => [['ref']]
    },
    'Faker::Json' => {
      'add_depth_to_json' => [['json'], ['json', 'width'], ['json', 'width', 'options']],
      'shallow_json' => [['width'], ['width', 'options']]
    },
    'Faker::Lorem' => {
      'characters' => [['number']],
      'paragraph' => [
        ['sentence_count'],
        ['sentence_count', 'supplemental'],
        ['sentence_count', 'supplemental', 'random_sentences_to_add']
      ],
      'paragraph_by_chars' => [['number'], ['number', 'supplemental']],
      'paragraphs' => [['number'], ['number', 'supplemental']],
      'question' => [
        ['word_count'],
        ['word_count', 'supplemental'],
        ['word_count', 'supplemental', 'random_words_to_add']
      ],
      'questions' => [['number'], ['number', 'supplemental']],
      'sentence' => [
        ['word_count'],
        ['word_count', 'supplemental'],
        ['word_count', 'supplemental', 'random_words_to_add']
      ],
      'sentences' => [['number'], ['number', 'supplemental']],
      'words' => [['number'], ['number', 'supplemental']]
    },
    'Faker::LoremFlickr' => {
      'colorized_image' => [
        ['size'],
        ['size', 'color'],
        ['size', 'color', 'search_terms'],
        ['size', 'color', 'search_terms', 'match_all']
      ],
      'grayscale_image' => [['size'], ['size', 'search_terms'], ['size', 'search_terms', 'match_all']],
      'image' => [['size'], ['size', 'search_terms'], ['size', 'search_terms', 'match_all']],
      'pixelated_image' => [['size'], ['size', 'search_terms'], ['size', 'search_terms', 'match_all']]
    },
    'Faker::LoremPixel' => {
      'image' => [
        ['size'],
        ['size', 'is_gray'],
        ['size', 'is_gray', 'category'],
        ['size', 'is_gray', 'category', 'number'],
        ['size', 'is_gray', 'category', 'number', 'text'],
        ['size', 'is_gray', 'category', 'number', 'text', 'secure']
      ]
    },
    'Faker::Markdown' => {
      'sandwich' => [['sentences'], ['sentences', 'repeat']]
    },
    'Faker::Measurement' => {
      'height' => [['amount']],
      'length' => [['amount']],
      'metric_height' => [['amount']],
      'metric_length' => [['amount']],
      'metric_volume' => [['amount']],
      'metric_weight' => [['amount']],
      'volume' => [['amount']],
      'weight' => [['amount']]
    },
    'Faker::Name' => {
      'initials' => [['number']]
    },
    'Faker::NationalHealthService' => {
      'check_digit' => [['number']]
    },
    'Faker::Number' => {
      'between' => [['from'], ['from', 'to']],
      'decimal' => [['l_digits'], ['l_digits', 'r_digits']],
      'decimal_part' => [['digits']],
      'hexadecimal' => [['digits']],
      'leading_zero_number' => [['digits']],
      'negative' => [['from'], ['from', 'to']],
      'normal' => [['mean'], ['mean', 'standard_deviation']],
      'number' => [['digits']],
      'positive' => [['from'], ['from', 'to']],
      'within' => [['range']]
    },
    'Faker::PhoneNumber' => {
      'extension' => [['length']],
      'subscriber_number' => [['length']]
    },
    'Faker::Placeholdit' => {
      'image' => [
        ['size'],
        ['size', 'format'],
        ['size', 'format', 'background_color'],
        ['size', 'format', 'background_color', 'text_color'],
        ['size', 'format', 'background_color', 'text_color', 'text']
      ]
    },
    'Faker::Relationship' => {
      'familial' => [['connection']]
    },
    'Faker::Source' => {
      'hello_world' => [['lang']],
      'print_1_to_10' => [['lang']]
    },
    'Faker::String' => {
      'random' => [['length']]
    },
    'Faker::Stripe' => {
      'ccv' => [['card_type']],
      'invalid_card' => [['card_error']],
      'valid_card' => [['card_type']],
      'valid_token' => [['card_type']]
    },
    'Faker::Time' => {
      'backward' => [['days'], ['days', 'period'], ['days', 'period', 'format']],
      'between' => [['from', 'to'], ['from', 'to', 'format']],
      'forward' => [['days'], ['days', 'period'], ['days', 'period', 'format']]
    },
    'Faker::Types' => {
      'complex_rb_hash' => [['number']],
      'rb_array' => [['len']],
      'rb_hash' => [['number'], ['number', 'node_type']],
      'rb_integer' => [['from'], ['from', 'to']],
      'rb_string' => [['words']]
    },
    'Faker::Vehicle' => {
      'kilometrage' => [['min'], ['min', 'max']],
      'license_plate' => [['state_abbreviation']],
      'mileage' => [['min'], ['min', 'max']],
      'model' => [['make_of_model']]
    },
    'Faker::WorldCup' => {
      'group' => [['group']],
      'roster' => [['country'], ['country', 'node_type']]
    },
    'Faker::Movies::StarWars' => {
      'quote' => [['character']]
    }
  }

  within_files Synvert::ALL_RUBY_FILES do
    with_node node_type: 'send', receiver: /\AFaker::/ do
      class_name = node.receiver.to_source
      methods = FAKER_USE_KEYWORD_ARGUMENTS_MAPPING[class_name]
      next unless methods

      methods.each do |method_name, keyword_names_array|
        keyword_names_array.each do |keyword_names|
          with_node node_type: 'send', message: method_name, arguments: { size: keyword_names.size } do
            new_arguments = keyword_names.map.with_index { |keyword_name, index|
              keyword_name == 'options' ? "options: #{add_curly_brackets_if_necessary(node.arguments[index].to_source)}" : "#{keyword_name}: {{arguments.#{index}}}"
            }.join(', ')
            replace :arguments, with: new_arguments
          end
        end
      end
    end
  end
end
