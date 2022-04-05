local typedefs = require "kong.db.schema.typedefs"

return {
  name = "01-my-plugin",
  fields = {
    { consumer  = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { exit_code = { type = "number", default = 200, one_of = { 200, 401, 402 }, }, },
        },
      },
    },
  },
}

