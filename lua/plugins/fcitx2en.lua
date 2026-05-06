local english_input_method = "keyboard-us"

local function switch_to_english()
  if vim.fn.executable("fcitx5-remote") ~= 1 then
    return
  end

  vim.fn.jobstart({ "fcitx5-remote", "-s", english_input_method }, {
    detach = true,
  })
end

local function is_normal_mode(mode)
  return mode:sub(1, 1) == "n"
end

local group = vim.api.nvim_create_augroup("Fcitx2En", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "InsertLeave", "CmdlineLeave", "FocusGained", "BufEnter" }, {
  group = group,
  callback = function()
    if is_normal_mode(vim.api.nvim_get_mode().mode) then
      switch_to_english()
    end
  end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = group,
  callback = switch_to_english,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = group,
  pattern = "*:*",
  callback = function()
    if is_normal_mode(vim.v.event.new_mode) then
      switch_to_english()
    end
  end,
})

return {}
