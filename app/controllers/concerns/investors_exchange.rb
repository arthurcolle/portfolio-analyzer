module InvestorsExchange extend ActiveSupport::Concern
  #
  # See the bottom of this file for sample data.
  #
  # Make data request(s) for symbols and return results in trades.
  def fillTrades(symbols, trades)
    begin
      symbolList = symbols.join(',')
      puts "IEX PRICE FETCH BEGIN for: #{symbolList}"
      # TODO put conn creation in session variable to cut overhead?
      conn = Faraday.new(url: 'https://api.iextrading.com/1.0/stock/market/batch?types=quote&filter=companyName,latestPrice,change,latestUpdate')
      resp = conn.get '', {symbols: symbolList}
      fetchTime = DateTime.now
      puts "IEX PRICE FETCH END   for: #{symbolList}"
      response = JSON.parse(resp.body)
    rescue Faraday::ClientError => e  # Can't connect. Error out all symbols.
      puts "IEX PRICE FETCH ERROR for: #{symbolList}: Faraday client error: #{e}"
      fetch_failure(symbols, trades, 'The feed is down.')
    rescue SyntaxError => e
      puts "IEX PRICE FETCH ERROR for: #{symbolList}: JSON parse error: #{e}"
      fetch_failure(symbols, trades, 'The feed is down.')
    else
      # TODO If symbols.length != response.length, something went wrong.
      #
      # Error example:
      #   <no errors defined yet>
      # Missing data for symbol example:
      #   {"symbol":"XXX","companyName":"","primaryExchange":"","sector":"","calculationPrice":"previousclose","open":null,"openTime":null,"close":null,"closeTime":null,"latestPrice":null,"latestSource":"N/A","latestTime":"N/A","latestUpdate":null,"latestVolume":0,"delayedPrice":null,"delayedPriceTime":null,"previousClose":null,"change":null,"changePercent":null,"iexMarketPercent":null,"avgTotalVolume":0,"marketCap":null,"peRatio":null,"week52High":0,"week52Low":0,"ytdChange":0}
      #
      symbols.each_with_index { |symbol, i|
        symbolTick = response[symbol]['quote']
        if symbolTick.nil? || symbolTick['companyName'].length == 0
          trade = error_trade(symbol, 'Price is not available.')
        else
          # TODO Need proper timezone info.
          trade = Trade.new do |t|
            t.stock_symbol = StockSymbol.find_by(name: symbol)
            t.trade_date   = Time.at(symbolTick['latestUpdate'].to_f/1000.0).round(4).to_datetime
            t.trade_price  = symbolTick['latestPrice'].to_f.round(4)
            t.price_change = symbolTick['change'].to_f.round(4)
            t.created_at   = fetchTime
          end
        end
        trades[i] = trade
      }
    end
  end
end

###################
##  SAMPLE DATA  ##
###################
#
# https://api.iextrading.com/1.0/stock/market/batch?types=quote&filter=companyName,latestPrice,change,latestUpdate&symbols=aapl,msft
# {
#  AAPL: {
#   quote: {
#    companyName	"Apple Inc."
#    latestPrice	172.5
#    change	4.39
#    latestUpdate	1509739200293
#   }
#  },
#  MSFT: {
#   quote: {
#    companyName	"Microsoft Corporation"
#    latestPrice	84.4
#    change	1.09
#    latestUpdate	1509739220275
#   }
#  }
# }
