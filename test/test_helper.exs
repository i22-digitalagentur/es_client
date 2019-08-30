Application.load(:es_client)
Application.ensure_all_started(:mox)

ExUnit.start()

Mox.defmock(ESClient.Drivers.Mock, for: ESClient.Driver)
Mox.defmock(MockJSONCodec, for: JSONCodec)
