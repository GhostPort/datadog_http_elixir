# DatadogHttp

[![Module Version](https://img.shields.io/hexpm/v/datadog_http.svg)](https://hex.pm/packages/datadog_http)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/datadog_http/)
[![Total Download](https://img.shields.io/hexpm/dt/datadog_http.svg)](https://hex.pm/packages/datadog_http)
[![License](https://img.shields.io/hexpm/l/datadog_http.svg)](https://github.com/GhostPort/datadog_http_elixir/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/GhostPort/datadog_http_elixir.svg)](https://github.com/GhostPort/datadog_http_elixir/commits/master)
[![Coverage Status](https://coveralls.io/repos/github/GhostPort/datadog_http_elixir/badge.svg?branch=master)](https://coveralls.io/github/GhostPort/datadog_http_elixir?branch=master)

A client for Datadog's HTTP API, useful for building integrations.

_This community library is not an official product or project of Datadog. Maintainers are not affiliated with Datadog in any way._

### Supported endpoints

- [ ] Audit
- [ ] Authentication
- [ ] AuthN Mappings
- [ ] AWS Integration
- [ ] AWS Logs Integration
- [ ] Azure Integration
- [ ] Cloud Workload Security
- [ ] Dashboard Lists
- [ ] Dashboards
- [ ] Downtimes
- [ ] Embeddable Graphs
- [ ] Events
  - [ ] Get a list of events
  - [x] Post an event
  - [ ] Get an event
  - [ ] Search events
- [ ] GCP Integration
- [ ] Hosts
- [ ] Incident Services
- [ ] Incident Teams
- [ ] Incidents
- [ ] IP Ranges
- [ ] Key Management
- [ ] Logs
- [ ] Logs Archives
- [ ] Logs Indexes
- [ ] Logs Metrics
- [ ] Logs Pipelines
- [ ] Logs Restriction Queries
- [ ] Metrics
  - [ ] Create a tag configuration
  - [ ] Get active metrics list
  - [ ] Submit distribution points
  - [x] Submit metrics
  - [ ] Get metric metadata
  - [ ] List tag configuration by name
  - [ ] Edit metric metadata
  - [ ] Update a tag configuration
  - [ ] Delete a tag configuration
  - [ ] Search metrics
  - [ ] Get a list of metrics
  - [ ] Query timeseries points
  - [ ] List tags by metric name
  - [ ] List active tags and aggregations
  - [ ] List distinct metric volumes by metric name
  - [ ] Configure tags for multiple metrics
  - [ ] Tag Configuration Cardinality Estimator
- [ ] Monitors
- [ ] Notebooks
- [ ] Opsgenie Integration
- [ ] Organizations
- [ ] PagerDuty Integration
- [ ] Processes
- [ ] Roles
- [ ] RUM
- [ ] Screenboards
- [ ] Security Monitoring
- [ ] Service Accounts
- [ ] Service Checks
- [ ] Service Dependencies
- [ ] Service Level Objective Corrections
- [ ] Service Level Objectives
- [ ] Slack Integration
- [ ] Snapshots
- [ ] Synthetics
- [ ] Tags
- [ ] Timeboards
- [ ] Usage Metering
- [ ] Users
- [ ] Webhooks Integration

## Installation

Add to your dependencies in `mix.exs`. The hex specification is required.

```elixir
def deps do
  [
    {:datadog_http, "~> 0.0.1"}
  ]
end
```

## Configuration

All calls to Datadog require an API key. Add the following configuration
to your project to set the values. This configuration is optional, see below for a
runtime configuration. The library will raise an error if the relevant credentials
are not provided either via `config.exs` or at runtime.

```elixir
config :datadog_http,
  base_url: "https://api.datadoghq.com",
  api_key: "your_client_id",
  adapter: Tesla.Adapter.Hackney, # optional
  http_options: [timeout: 10_000, recv_timeout: 30_000] # optional
```

By default, `base_url` is set to the main datadog API endpoint (`https://api.datadoghq.com`).

## Runtime configuration

Alternatively, you can provide the configuration at runtime. The configuration passed
as a function argument will overwrite the configuration in `config.exs`, if one exists.

For example, if you want to hit a different URL when calling the metrics submission endpoint, you could
pass in a configuration argument to `DatadogHttp.Metrics.submit/2`.

```elixir
DatadogHttp.Metrics.submit(
  [],
  %{base_url: "https://api.datadoghq.eu", api_key: "an-api-key"}
)
```
