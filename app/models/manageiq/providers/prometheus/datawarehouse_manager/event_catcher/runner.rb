class ManageIQ::Providers::Prometheus::DatawarehouseManager::EventCatcher::Runner <
  ManageIQ::Providers::BaseManager::EventCatcher::Runner

  TAG_EVENT_TYPE    = "miq.event_type".freeze # required by fetch
  TAG_RESOURCE_TYPE = "miq.resource_type".freeze # optionally provided when linking to a resource

  def initialize(cfg = {})
    super
  end

  def reset_event_monitor_handle
    @event_monitor_handle = nil
  end

  def stop_event_monitor
    @event_monitor_handle.try(:stop)
  ensure
    reset_event_monitor_handle
  end

  def monitor_events
    event_monitor_handle.start
    event_monitor_handle.each_batch do |events|
      event_monitor_running
      if events.any?
        $mw_log.debug "#{log_prefix} Queueing events #{events}"
        @queue.enq events
      end
      # invoke the configured sleep before the next event fetch
      sleep_poll_normal
    end
  ensure
    reset_event_monitor_handle
  end

  def process_event(event)
    event_hash = event_to_hash(event, @cfg[:ems_id])

    if blacklist?(event_hash[:event_type])
      $mw_log.debug "#{log_prefix} Filtering blacklisted event [#{event}]"
    else
      $mw_log.debug "#{log_prefix} Adding ems event [#{event_hash}]"
      EmsEvent.add_queue('add', @cfg[:ems_id], event_hash)
    end
  end

  private

  def event_monitor_handle
    @event_monitor_handle ||= ManageIQ::Providers::Prometheus::DatawarehouseManager::EventCatcher::Stream.new(@ems)
  end

  def blacklist?(event_type)
    filtered_events.include?(event_type)
  end

  def event_to_hash(event, ems_id = nil)
    puts "event_to_hash event: #{event}"
    event.event_type = event.tags[TAG_EVENT_TYPE]
    if event.context
      event.message        = event.context['message'] # optional, prefer context message if provided
      event.prometheus_ref = event.context['resource_path'] # optional context for linking to resource
    end
    event.message ||= event.text
    # at time of writing the timeline can not handle newlines or double quotes in the message. Because the
    # timeline popup is not meant to show huge messages, like stack traces, just truncate after the first line.
    # And replace double quotes with single quotes.
    unless event.message.nil?
      event.message = event.message.lines.first.strip
      event.message.tr!('"', "'")
    end
    event.middleware_type = event.tags[TAG_RESOURCE_TYPE] # optional tag for linking to resource
    {
      :ems_id          => ems_id,
      :source          => 'HAWKULAR',
      :timestamp       => Time.zone.at(event.ctime / 1000),
      :event_type      => event.event_type,
      :message         => event.message,
      :middleware_ref  => event.middleware_ref,
      :middleware_type => event.middleware_type,
      :full_data       => event.to_s
    }
  end
end
