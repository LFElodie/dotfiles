local function fail(msg)
  io.stderr:write(msg .. "\n")
  vim.cmd("cquit 1")
end

local function main()
  vim.api.nvim_win_set_cursor(0, { 5, 0 })

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local pyrefly = vim.iter(clients):find(function(client)
    return client.name == "pyrefly"
  end)

  if not pyrefly then
    fail("pyrefly is not attached")
  end

  if not pyrefly.server_capabilities.definitionProvider then
    fail("pyrefly does not advertise definitionProvider")
  end

  local params = vim.lsp.util.make_position_params(0, "utf-8")
  local results = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 3000)
  if not results then
    fail("definition request returned nil")
  end

  local response = results[pyrefly.id]
  if not response or not response.result or vim.tbl_isempty(response.result) then
    fail("definition request returned no locations")
  end

  print("python lsp smoke passed")
  vim.cmd("qa!")
end

vim.defer_fn(main, 1500)
