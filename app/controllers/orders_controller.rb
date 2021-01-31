require 'json'
class OrdersController < ApplicationController
    before_action :get_statuses, only: :show
    URL = "https://app.realhublive.com/api/v2/"
    HEADERS = {"x-api-token".to_sym => ENV["API_KEY"]}  
    def show
        @orders = get_orders[0..10]
        #Getting all orders takes too much time. I took just first 10 of them
        @order_infos = @orders.map do |order|
          order_items_ids = order['items'].map { |item| item['id'] }
          {
            agency: order['agency']['title'],
            campaing_address: "#{order['campaign']['address']}, #{order['campaign']['suburb_name']}",
            items: get_items_details(order_items_ids)
            # gets_items_details([234, 635, 2930, 4848])
            }
        end
    end

    private

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

    def get_artwork_status(id)
        @statuses.find {|status| status["id"] == id }["title"]
    end

    def get_statuses
        @statuses = JSON.parse(RestClient.get(URL + "statuses", HEADERS))
    end

    def get_orders
      JSON.parse(RestClient.get(URL + "orders.json?include_order_agency=true&include_order_campaign=true&include_order_items=true", HEADERS))
    end
end
