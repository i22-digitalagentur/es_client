import Config

config :exvcr, vcr_cassette_library_dir: "test/fixtures/vcr_cassettes"

config :es_client, TestClient,
  host: "http://elasticsearch:9201",
  driver: ESClient.Drivers.Mock,
  json_keys: :atoms,
  json_library: Jason,
  json_encoder: Jsonrs,
  timeout: 5000
