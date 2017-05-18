Vmdb::Gettext::Domains.add_domain(
  'ManageIQ_Providers_Prometheus',
  ManageIQ::Providers::Prometheus::Engine.root.join('locale').to_s,
  :po
)
