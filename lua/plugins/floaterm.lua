local G = require("G")
return {
  "voldikss/vim-floaterm",
  config = function()
    -- toggleFT func: 存在对应名称的窗口则toggle，否则新建
    function _ToggleFT(name, cmd)
      if G.fn["floaterm#terminal#get_bufnr"](name) ~= -1 then
        G.cmd(string.format('exec "FloatermToggle %s"', name))
      else
        G.cmd(string.format("FloatermNew --name=%s %s", name, cmd))
      end
    end

    -- 用于快速设定floatterm的相关map
    function SetFTToggleMap(key, name, cmd)
      G.map({
        {
          "n",
          key,
          "<cmd>lua _ToggleFT('" .. name .. "','" .. cmd .. "')<cr>",
          { noremap = true, silent = true },
        },
        {
          "t",
          key,
          "&ft == \"floaterm\" ? printf('<c-\\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('"
          .. name
          .. "') == bufnr('%') ? '' : '"
          .. key
          .. "') : '"
          .. key
          .. "'",
          { silent = true, expr = true },
        },
      })
    end

    SetFTToggleMap("<leader>t", "TERM", "")

    -- 特殊func 定义了F5行为时根据当前文件类型调用不同的命令
    function _RunFile()
      G.cmd("w")
      local ft = G.eval("&ft")
      local run_cmd = {
        javascript = "node",
        typescript = "ts-node",
        html = "google-chrome-stable",
        python = "python3",
        go = "go run",
        sh = "bash",
        lua = "lua",
      }
      if run_cmd[ft] then
        _ToggleFT("RUN", run_cmd[ft] .. " %")
      elseif ft == "markdown" then
        G.cmd("MarkdownPreview")
      elseif ft == "c" then
        _ToggleFT("RUN", "gcc % -o %< && ./%< && rm %<")
      end
    end

    G.map({
      { "n", "<F5>", ":lua _RunFile()<cr>",      { silent = true, noremap = true } },
      { "i", "<F5>", "<esc>:lua _RunFile()<cr>", { silent = true, noremap = true } },
      {
        "t",
        "<F5>",
        "&ft == \"floaterm\" ? printf('<c-\\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('RUN') == bufnr('%') ? '' : '<F6>') : '<F6>'",
        { silent = true, expr = true },
      },
    })
  end,
}
