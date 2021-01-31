require 'json'
class OrdersController < ApplicationController
   URL = "https://app.realhublive.com/api/v2/"
   HEADERS = {"x-api-token".to_sym => ENV["API_KEY"]}

   def show
      @orders = get_orders[0..10]
      @orders.map! do |order|
        {
          agency: order['agency']['title'],
          campaing_address: get_campaign_address(order['campaign_id']),
          items: get_items_details(order['items'].map { |item| item['id'] })
        }
      end
    end

    private

    def get_campaign_address(id)
      return nil unless id
      response =  JSON.parse(RestClient.get(URL + "campaigns/#{id}.json", HEADERS ))
      puts "Address"
      "#{response['address']}, #{response['suburb_name']}"
    end

    def get_items_details(items_ids)
      items_ids.map do |item_id|
      response = JSON.parse(RestClient.get(URL + "order_items/#{item_id}.json?include_order_item_artwork=true", HEADERS))
        {
          item_name: response["title"],
          status: get_artwork_status(response["status_id"]),
          item_link: response["artwork"] && response["artwork"]["links"]["download_url"]
       }
      end
    end

    def get_orders
      JSON.parse(RestClient.get(URL + "orders.json?include_order_agency=true&include_order_items=true", HEADERS))
    end

    def get_artwork_status(id)
      response = RestClient.get(URL + "statuses", HEADERS)
      JSON.parse(response).find {|status| status["id"] == id }["title"]
    end
end
