local keymap = vim.api.nvim_set_keymap

--Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

keymap("i", "<esc>", "<esc>:w<return>:noh<return><esc>", { noremap = true })
keymap("n", "<esc>", ":w<return>:noh<return>", { noremap = true })

-- Y yank until the end of line
keymap("n", "Y", "y$", { noremap = true })
-- U redo
keymap("n", "U", "<C-r>", { noremap = true })
-- Q quit
keymap("n", "Q", ":q<cr>", { noremap = true })

keymap("i", "<C-h>", "<left>", { noremap = true })
keymap("i", "<C-l>", "<right>", { noremap = true })

-- window switch
keymap("", "<C-h>", "<C-w>h", { noremap = true })
keymap("", "<C-j>", "<C-w>j", { noremap = true })
keymap("", "<C-k>", "<C-w>k", { noremap = true })
keymap("", "<C-l>", "<C-w>l", { noremap = true })

-- buffer switch
keymap("n", "J", ":bp<cr>", { noremap = true })
keymap("n", "K", ":bn<cr>", { noremap = true })

-- split window
keymap("n", "<C-w>h", ":abo vsplit <cr>", { noremap = true })
keymap("n", "<C-w>j", ":rightbelow split <cr>", { noremap = true })
keymap("n", "<C-w>k", ":abo split <cr>", { noremap = true })
keymap("n", "<C-w>l", ":rightbelow vsplit <cr>", { noremap = true })
-- resize window
keymap("n", "<up>", ":resize +2 <cr>", { noremap = true })
keymap("n", "<down>", ":resize -2 <cr>", { noremap = true })
keymap("n", "<left>", ":vertical resize +2 <cr>", { noremap = true })
keymap("n", "<right>", ":vertical resize -2 <cr>", { noremap = true })

-- buffer manager
keymap("n", "<leader>bp", ":bp<cr>", { noremap = true })
keymap("n", "<leader>bn", ":bn<cr>", { noremap = true })
keymap("n", "<leader>bd", ":bd<cr>", { noremap = true })
keymap("n", "<leader>bl", ":ls<cr>", { noremap = true })
keymap("n", "<leader>bo", ":enew<cr>", { noremap = true })

-- copy/paste
keymap("v", "<leader>y", '"+y', { noremap = true })
keymap("n", "<leader>y", '"+y', { noremap = true })
keymap("n", "<leader>Y", '"+yg_', { noremap = true })

keymap("v", "<leader>p", '"+p', { noremap = true })
keymap("n", "<leader>p", '"+p', { noremap = true })
keymap("n", "<leader>P", '"+P', { noremap = true })

-- Add move/indent lines shortcuts
keymap("v", "J", ":m '>+1<CR>gv=gv", { noremap = true })
keymap("v", "K", ":m '<-2<CR>gv=gv", { noremap = true })
keymap("x", "<", "<gv", { noremap = true })
keymap("x", ">", ">gv", { noremap = true })
