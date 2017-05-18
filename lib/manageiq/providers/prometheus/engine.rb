module ManageIQ
  module Providers
    module Prometheus
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::Prometheus
      end
    end
  end
end
