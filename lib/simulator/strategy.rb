require 'json'
require 'net/http'
require 'uri'

class Strategy
  BET = 'bet'
  INSURANCE = 'insurance'
  SURRENDER = 'surrender'
  DOUBLE = 'double'
  SPLIT = 'split'
  STAND = 'stand'
  PLAY = 'play'

  attr_accessor :playbook, :number_of_cards, :json_object

  def initialize(playbook, number_of_cards)
    @playbook = playbook
    @number_of_cards = number_of_cards
    @json_object = nil
    @url_bet = "http://#{get_strategy_url}/#{BET}"
    @url_insurance = "http://#{get_strategy_url}/#{INSURANCE}"
    @url_surrender = "http://#{get_strategy_url}/#{SURRENDER}"
    @url_double = "http://#{get_strategy_url}/#{DOUBLE}"
    @url_split = "http://#{get_strategy_url}/#{SPLIT}"
    @url_stand = "http://#{get_strategy_url}/#{STAND}"
    @url_play = "http://#{get_strategy_url}/#{PLAY}"
  end

  def get_bet(seen_cards)
    @json_object = nil
    params = build_params(seen_cards, nil, nil, nil)
    json_response = http_get(@url_bet, params)
    json_response[BET].to_i
  end

  def get_insurance(seen_cards)
    params = build_params(seen_cards, nil, nil, nil)
    json_response = http_get(@url_insurance, params)
    json_response[INSURANCE] == true
  end

  def get_surrender(seen_cards, have_cards, up_card)
    return @json_object[SURRENDER] if @json_object
    params = build_params(seen_cards, have_cards, nil, up_card)
    json_response = http_get(@url_surrender, params)
    json_response[SURRENDER] == true
  end

  def get_double(seen_cards, have_cards, up_card)
    return @json_object[DOUBLE] if @json_object
    params = build_params(seen_cards, have_cards, nil, up_card)
    json_response = http_get(@url_double, params)
    json_response[DOUBLE] == true
  end

  def get_split(seen_cards, pair_card, up_card)
    return @json_object[SPLIT] if @json_object
    params = build_params(seen_cards, nil, pair_card, up_card)
    json_response = http_get(@url_split, params)
    json_response[SPLIT] == true
  end

  def get_stand(seen_cards, have_cards, up_card)
    return @json_object[STAND] if @json_object
    # puts "get_stand #{have_cards}"
    params = build_params(seen_cards, have_cards, nil, up_card)
    json_response = http_get(@url_stand, params)
    json_response[STAND] == true
  end

  def do_play(seen_cards, have_cards, pair_card, up_card)
    params = build_params(seen_cards, have_cards, pair_card, up_card)
    @json_object = http_get(@url_play, params)
  end

  def clear
    @json_object = nil
  end

  private

  def build_params(seen_data, have_data, pair_card, up_card)
    params = {
      playbook: @playbook,
      cards: @number_of_cards
    }
    params[:up] = up_card.offset if up_card
    params[:pair] = pair_card.value if pair_card
    params[:seen] = seen_data.to_json if seen_data
    params[:have] = have_data.to_json if have_data
    URI.encode_www_form(params)
  end

  def http_get(url, params)
    uri = URI(url)
    uri.query = params
  
    response = nil
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)
      response = http.request(request) # Send the GET request
    end
  
    JSON.parse(response.body)
  end

  def http_getX(url, params)
    uri = URI(url)
    uri.query = params
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def get_strategy_url
    ENV['STRIKER_URL_ACE']
  end
end
