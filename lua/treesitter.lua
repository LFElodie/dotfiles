local ts_config = require('nvim-treesitter.configs')

ts_config.setup {
    ensure_installed = {
        'c', 'cpp', 'css', 'bash', 'html', 'javascript', 'lua', 'typescript'
    };
    highlight = {enable = true, use_languagetree = true};
    indent_on_enter = { enable = true };
    indent = {enable = true}
}
