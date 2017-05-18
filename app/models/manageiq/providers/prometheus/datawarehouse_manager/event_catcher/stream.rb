class ManageIQ::Providers::Prometheus::DatawarehouseManager::EventCatcher::Stream
  def initialize(ems)
    @ems               = ems
    @collecting_events = false
  end

  def start
    @collecting_events = true
  end

  def stop
    @collecting_events = false
  end

  def each_batch
    while @collecting_events
      yield fetch
    end
  end

  private

  # Each fetch is performed from the time of the most recently caught event or 1 minute back for the first poll.
  # This gives us some slack if hawkular events are timestamped behind the miq server time.
  # Note: This assumes all Hawkular events at max-time T are fetched in one call. It is unlikely that there
  # would be more than one for the same millisecond, and that the query would be performed in the midst of
  # writes for the same ms. It may be a feasible scenario but I think it's unnecessary to handle it at this time.
  def fetch
    endpoint = "http://#{@ems.hostname}"
    connection = Faraday.new(endpoint) do |conn|
      conn.response :json, :content_type => /\bjson$/

      conn.adapter Faraday.default_adapter
    end
    json_response = connection.get('/api/v1/alerts')
    json_response.body[:data] || []
  rescue => err
    $mw_log.info "Error capturing events #{err}"
    []
  end
end
