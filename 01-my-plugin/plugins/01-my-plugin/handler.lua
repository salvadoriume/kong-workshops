-- System
local ngx         = ngx
local kong        = kong
local utils       = require "kong.tools.utils"
local opkey       = require "resty.openssl.pkey"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"

-- luacheck: push ignore 211
local plugin = {
  NAME     = "01-my-plugin",
  PRIORITY = 3000
}
-- luacheck: pop

local function do_authentication(config)
    local authHeader = kong.request.get_header("Authorization")
    if authHeader ~= nil then
      if string.match(string.lower(authHeader), 'bearer') ~= nil then
        local token = string.sub(authHeader, 8)

        local token_type = type(token)
        if token_type ~= "string" then
          if token_type == "nil" then
            return false, "Unauthorized"
          elseif token_type == "table" then
            return false, "Multiple tokens provided"
          else
            return false, "Unrecognizable token"
          end
        end

        local jwt, err = jwt_decoder:new(token)
        if err then
          return false, "Bad token; " .. tostring(err)
        end

        local ok, errors = jwt:verify_registered_claims({"exp"})                                                                                                                                                                                                                                                 
        if not ok then                                                                                                                                                                                                                                                                                                  
          return false, errors.nbf or errors.exp                                                                                                                                                                                                                                                                   
        end         

        local jwt_username = jwt.claims.Username
        if jwt_username ~= nil then
          kong.ctx.plugin.username = jwt.claims.Username
        end

      end
    end
    return true
end

function plugin:new(config)
  plugin.super.new(self, plugin.NAME)
end

function plugin:response(config)
  local jwt_username = kong.ctx.plugin.username
  if jwt_username ~= nil then
    kong.response.set_header("JWT-username", jwt_username)
  end
end

function plugin:access(config)
  if kong.request.get_method() == "OPTIONS" then                                                                                                                                                                                                                                                                        
    return                                                                                                                                                                                                                                                                                                              
  end         

  local ok, err = do_authentication(config)
  if not ok then
    kong.response.exit(config.exit_code, string.format("JwtError: %s", err))
  end
end

return plugin

