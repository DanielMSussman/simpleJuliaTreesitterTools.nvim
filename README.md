So far this repo just tests out adhering to naming conventions in Julia via treesitter.
This obviously cannot be completely correct, but for most cases I think treesitter should be able to handle things.
The current functionality is a best-effort attempt to check that modules, types, constants, and functions have the correct case.
Violations of naming conventions are sent to the quickfix list.
Here's a brief demo checking the ForwardDiff.jl package, then monkeying around in it to generate some violations:

https://github.com/user-attachments/assets/dde15d57-86c9-4f86-bca1-86b14d234bbf

In order to handle constructors (which look like functions as far as treesitter is concerned, of course), we first enumerate all type definitions and then do not report potential naming violations for functions that have the same name as an existing type.
So far this all works reasonably well, although I'm sure there are corner cases that are outside of my (or treesitter's?) ability to correctly parse.

There is also a half-finished experimental implementation that tries to interface with the LanguageServer.jl LSP for everything; this works poorly (if at all) -- I was surprised that LSP-based enforcement wasn't already an option, but I'm sure a smarter, functional implementation is out there somewhere.

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
                ["Constant"] = "SCREAMING_SNAKE_CASE",
                ["Module"] = "UpperCamelCase",
                ["Struct"] = "UpperCamelCase",
                ["AbstractType"] = "AbstractUpperCamelCase",
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

## To-do

Any number of improvements could be made, and of course I'll probably want some other (e.g.) treesitter-based text objects to use for purposes other than linting. 
On the naming conventions, I just noticed that guides enforce variable name conventions, too... I'm not sure about that (vectors and matrices, right?), but the current pattern of filtering future queries could be used to handle this.


### Thanks?

If, for some unexpected reason, you found this helpful and would like to offer support: [Buy Me a Coffee!](https://www.buymeacoffee.com/danielmsussman)
