require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "E", "$", { desc = "Go to end of line"})
map("n", "B", "^", { desc = "Go to first non-blank character" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
