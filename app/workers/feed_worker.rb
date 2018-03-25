# This class is responsible for executing feed-related SideKiq jobs.
class FeedWorker
  include Sidekiq::Worker
  # Perform the specified task (in a worker thread).
  def perform(name)
    case name
    when 'instrument_bulk_load'
      feed_records = Feed.symbology  # Call feed handler to retrieve symbology.
      DataCache.instrument_bulk_load(feed_records)
    when 'price_bulk_load'
      instruments = Instrument.select(:id, :symbol)  # Get instrument list.
      DataCache.price_values(instruments, true)
    when 'series_bulk_load_all'
      instruments = Instrument.select(:id, :symbol)  # Get series data for all instruments.
      DataCache.series_bulk_load(instruments)
    when 'series_bulk_load_new'
      instruments = Instrument.select(:id, :symbol).where.not(id: Series.select('instrument_id').distinct)  # Get series data for instruments not yet in Series table.
# instruments = Instrument.select(:id, :symbol).where("symbol like 'AIM%'")  # Get series data for instruments not yet in Series table.
      DataCache.series_bulk_load(instruments)
    else
      "FeedWorker Error: invalid request (#{name})"
    end
    nil
  end
end
