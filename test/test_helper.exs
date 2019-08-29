ExUnit.start()

Mox.defmock(ESClient.Drivers.Mock, for: ESClient.Driver)
Mox.defmock(MockJSONCodec, for: JSONCodec)
