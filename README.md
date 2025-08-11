I wanted to test out linting Julia naming conventions via treesitter
The current functionality is a best-effort attempt to check that modules, types, constants, and functions have the correct case.
Violations of naming conventions are sent to the quickfix list.

There is also a half-finished experimental implementation that tries to interface with the LanguageServer.jl LSP for everything; this works poorly.

## Installation, configuration, and requirements

This uses the neovim >0.11 way of iterating through treesitter queries

Using [lazy.nvim](https://github.com/folke/lazy.nvim), installation is just
```lua 
{
    "DanielMSussman/simpleJuliaTreesitterTools.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter'},
    ft = "julia",
}
```

There are a small handful of default options that can be changed by passing options to the setup function. A more complete lazy config with all currently available options and keymaps that access the accessible functions:
```lua
{
    "DanielMSussman/simpleJuliaTreesitterTools.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter'},
    ft = "julia",
    config = function()
        require("simpleJuliaTreesitterTools").setup({
            rules = {
                ["Constant"] = "screaming_snake_case",
                ["Module"] = "UpperCamelCase",
                ["Struct"] = "UpperCamelCase",
                ["AbstractType"] = "UpperCamelCase",
                ["Function"] = "snake_case",
            },
            defaultApproach = "treesitter", --or "lsp"...
        })
        vim.keymap.set('n', '<localleader>lb', function()
            require('simpleJuliaTreesitterTools').lint_buffer_names()
        end, { desc = '[L]int names in current [b]uffer' })

        vim.keymap.set('n', '<localleader>lp', function()
            require('simpleJuliaTreesitterTools').lint_project_names()
        end, { desc = '[L]int names in current [p]roject' })
    end
}
```



### Thanks?

If, for some unexpected reason, you found this helpful and would like to offer support:

[![Buy Me a Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-blue.png)](https://www.buymeacoffee.com/danielmsussman)
