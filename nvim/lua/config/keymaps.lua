local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer", silent = true })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window", silent = true })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer", silent = true })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
map("n", "<leader>h", "<C-w>h", { desc = "Focus left window" })
map("n", "<leader>j", "<C-w>j", { desc = "Focus lower window" })
map("n", "<leader>k", "<C-w>k", { desc = "Focus upper window" })
map("n", "<leader>l", "<C-w>l", { desc = "Focus right window" })
