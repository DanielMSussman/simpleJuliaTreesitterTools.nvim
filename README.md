This lightweight collection of treesitter tools for Julia currently focuses just on violations of naming conventions.

It makes a best-effort attempt to parse your code and check that modules, types, constants, and functions adhere to your preferred case conventions.
It's smart enough -- since treesitter doesn't give us semantic information -- to identify all type definitions first, which helps it avoid incorrectly flagging constructors as function-naming violations.


### Features

- Targeted naming convention checks for Modules, Structs, Abstract Types, Constants, and Functions.
- Choose to lint the current buffer, the entire project, or specific directories.
- Configurable naming rules for compliance with your preferred style
- Reporting modes: `quickfix` to send all violations to the quickfix list for review or `jump` to jump to the first violation and then cycle through the rest.

### Demo


Here's a brief demo checking the ForwardDiff.jl package, then monkeying around in it to generate some violations:

https://github.com/user-attachments/assets/dde15d57-86c9-4f86-bca1-86b14d234bbf

Notice that in the above video when we change `Dual` to `dual` the previously unreported use of the constructors throws a potential flag.
So far this all works reasonably well, although I'm sure there are corner cases that are outside of my (or treesitter's?) ability to correctly parse.

There is also a half-finished experimental implementation that tries to interface with the LanguageServer.jl LSP for everything; this works poorly (if at all) -- I was surprised that LSP-based enforcement wasn't already an option, but I'm sure a smarter, functional implementation is out there somewhere.


## Requirements

* Neovim >= 0.11 (for the modern treesitter query API)
* [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)


## Installation and configuration

Install with your favorite plugin manager. Here's the minimal [lazy.nvim](https://github.com/folke/lazy.nvim) installation:
```lua 
{
    "DanielMSussman/simpleJuliaTreesitterTools.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter'},
    ft = "julia",
}
```

Here is a more complete configuration example showing all of the options and some recommended keymaps:
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
            defaultApproach = "treesitter",
            lint_action = "quickfix", -- "quickfix" or "jump"
            projectRootFile = "Project.toml",
            projectDirectory = "/src",
        })
        vim.keymap.set('n', '<localleader>lb', function()
            require('simpleJuliaTreesitterTools').lint_buffer_names()
        end, { desc = '[L]int names in current [b]uffer' })

        vim.keymap.set('n', '<localleader>lp', function()
            require('simpleJuliaTreesitterTools').lint_project_names()
        end, { desc = '[L]int names in current [p]roject' })

        vim.keymap.set('n', '<localleader>lc', function()
            require('simpleJuliaTreesitterTools').cycle_violations()
        end, { desc = '[L]inting: [c]ycle to next violation' })
    end
}
```

## Usage

The plugin provides three functions you can call or map to keys.

* `require('simpleJuliaTreesitterTools').lint_buffer_names()` finds naming violations in the current buffer
* `require('simpleJuliaTreesitterTools').lint_project_names()` finds the `projectRootFile` and lints all `.jl` files in the `projectDirectory`.
* `require('simpleJuliaTreesitterTools').cycle_violations()`: when `lint_action = "jump"`, this command will move the cursor to the next naming violation in the list.

## To-do
* Explore other treesitter-based actions I might want to do in Julia
* Investigate adding support for linting local variable names. 


### Thanks?

If, for some unexpected reason, you found this helpful and would like to offer support: [Buy Me a Coffee!](https://www.buymeacoffee.com/danielmsussman)
