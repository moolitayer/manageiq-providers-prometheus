module ManageIQ::Providers
  class Prometheus::DatawarehouseManager::Refresher < ManageIQ::Providers::BaseManager::Refresher
    include ::EmsRefresh::Refreshers::EmsRefresherMixin

    def parse_legacy_inventory(ems)
      ::ManageIQ::Providers::Prometheus::DatawarehouseManager::RefreshParser.ems_inv_to_hashes(ems)
    end
  end
end
