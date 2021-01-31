require 'json'
class OrdersController < ApplicationController
    URL = "https://app.realhublive.com/api/v2/"
    HEADERS = {"x-api-token".to_sym => ENV["API_KEY"]}  
    def show
        @orders = get_orders[0..10]
        #Getting all orders takes too much time. I took just first 10 of them
        
    end

    def get_orders
      pak = JSON.parse(RestClient.get(URL + "orders.json?include_order_agency=true&include_order_campaign=true&include_order_items=true", HEADERS))
    #   raise
    end
    
end
