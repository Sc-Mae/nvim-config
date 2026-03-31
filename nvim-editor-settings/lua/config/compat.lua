-- Neovim 0.12 compatibility shims for pinned plugins that still call removed
-- or deprecated APIs during startup.
if vim.fn.has "nvim-0.12" == 1 then
  vim.tbl_islist = vim.islist

  vim.tbl_flatten = function(t)
    local result = {}

    local function flatten(value)
      if type(value) ~= "table" or not vim.islist(value) then
        result[#result + 1] = value
        return
      end

      for _, item in ipairs(value) do
        flatten(item)
      end
    end

    flatten(t)
    return result
  end

  vim.tbl_add_reverse_lookup = function(t)
    for key, value in pairs(t) do
      if t[value] == nil then
        t[value] = key
      end
    end
    return t
  end
end

do
  local validate = vim.validate
  local validate_alias = {
    b = "boolean",
    c = "callable",
    f = "function",
    n = "number",
    s = "string",
    t = "table",
  }

  local function normalize_validator(validator)
    if type(validator) == "string" then
      return validate_alias[validator] or validator
    end

    if type(validator) == "table" and vim.islist(validator) then
      local normalized = {}
      for index, value in ipairs(validator) do
        normalized[index] = normalize_validator(value)
      end
      return normalized
    end

    return validator
  end

  vim.validate = function(name, value, validator, optional, message)
    if type(name) == "table" and value == nil then
      local keys = vim.tbl_keys(name)
      table.sort(keys)

      for _, field in ipairs(keys) do
        local spec = name[field]
        local is_optional = spec[3] == true
        local err_msg = type(spec[3]) == "string" and spec[3] or spec[4]
        validate(field, spec[1], normalize_validator(spec[2]), is_optional, err_msg)
      end

      return
    end

    return validate(name, value, normalize_validator(validator), optional, message)
  end
end

local function compat_patch_lsp_client(client)
  if type(client) ~= "table" or client._compat_methods_patched then
    return client
  end

  local mt = getmetatable(client)
  if type(mt) ~= "table" then
    return client
  end

  for _, method_name in ipairs { "request", "request_sync", "notify", "cancel_request", "stop", "is_stopped", "on_attach", "supports_method" } do
    local method = mt[method_name]
    if type(method) == "function" then
      client[method_name] = function(...)
        local self = select(1, ...)
        if self and getmetatable(self) == mt then
          return method(...)
        end
        return method(client, ...)
      end
    end
  end

  client._compat_methods_patched = true
  return client
end

if vim.lsp.start_client ~= nil then
  vim.lsp.start_client = function(config)
    local ok, client = pcall(require("vim.lsp.client").create, config)
    if not ok then
      return nil, client
    end

    compat_patch_lsp_client(client)
    client:initialize()
    return client.id, nil
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("nvim-compat-lsp", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client ~= nil then
      compat_patch_lsp_client(client)
    end
  end,
})

if vim.diagnostic.is_disabled == nil and vim.diagnostic.is_enabled ~= nil then
  ---@param bufnr? integer
  ---@param ns_id? integer
  vim.diagnostic.is_disabled = function(bufnr, ns_id)
    return not vim.diagnostic.is_enabled { bufnr = bufnr, ns_id = ns_id }
  end
end
