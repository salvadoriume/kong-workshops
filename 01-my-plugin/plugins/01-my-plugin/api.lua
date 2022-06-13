return {
  ["/my-plugin/ping"] = {
      GET = function(self)
        return kong.response.exit(200, "PONG")
      end
  },
}



