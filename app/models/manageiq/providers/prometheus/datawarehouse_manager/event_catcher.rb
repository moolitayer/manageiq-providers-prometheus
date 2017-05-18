class ManageIQ::Providers::Prometheus::DatawarehouseManager::EventCatcher < ManageIQ::Providers::BaseManager::EventCatcher
  require_nested :Runner

  def self.settings_name
    :event_catcher_prometheus_datawarehouse
  end
end
