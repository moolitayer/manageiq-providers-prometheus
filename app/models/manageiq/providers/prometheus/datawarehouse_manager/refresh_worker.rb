module ManageIQ::Providers
  class Prometheus::DatawarehouseManager::RefreshWorker < ManageIQ::Providers::BaseManager::RefreshWorker
    require_nested :Runner

    def self.ems_class
      ManageIQ::Providers::Prometheus::DatawarehouseManager
    end
  end
end
