return {
  {
    'nvim-neotest/neotest',
    dependencies = { 'nvim-neotest/neotest-python' },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('neotest').setup {
        adapters = {
          require 'neotest-python',
        },
      }
    end,
    keys = {
      { '<leader>dtt', ":lua require'neotest'.run.run({strategy = 'dap'})<cr>", desc = '[t]est' },
      { '<leader>dts', ":lua require'neotest'.run.stop()<cr>", desc = '[s]top test' },
      { '<leader>dta', ":lua require'neotest'.run.attach()<cr>", desc = '[a]ttach test' },
      { '<leader>dtf', ":lua require'neotest'.run.run(vim.fn.expand('%'))<cr>", desc = 'test [f]ile' },
      { '<leader>dts', ":lua require'neotest'.summary.toggle()<cr>", desc = 'test [s]ummary' },
    },
  },

  -- debug adapter protocol
  {
    'mfussenegger/nvim-dap',
    cmd = { 'DapContinue', 'DapToggleBreakpoint', 'DapStepOver', 'DapStepInto', 'DapStepOut', 'DapReplOpen' },
    dependencies = {
      {
        'rcarriga/nvim-dap-ui',
        dependencies = {
          'nvim-neotest/nvim-nio',
        },
      },
      'mfussenegger/nvim-dap-python',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      vim.fn.sign_define('DapBreakpoint', { text = '🦆', texthl = '', linehl = '', numhl = '' })
      local dap = require 'dap'

      local dapui_ok, ui = pcall(require, 'dapui')
      if dapui_ok then
        ui.setup()
      end

      -- Use uv to provide debugpy, while the launched program uses the
      -- project's local environment when one is available.
      require('dap-python').setup('uv', {
        console = 'integratedTerminal',
      })
      require('dap-python').test_runner = 'pytest'

      -- Script-mode launch for the editable Marimo builder.  This mirrors
      -- `uv run --script dataset_notebooks/build.py` without starting the
      -- interactive Marimo editor.
      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'launch',
        name = 'Marimo builder (script mode)',
        program = '${file}',
        python = { 'uv', 'run', '--script' },
        args = { '--execute' },
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        justMyCode = false,
      })

      require('nvim-dap-virtual-text').setup {
        -- Hides tokens, secrets, and other sensitive information
        -- From TJ DeVries' config
        -- Not necessary, but also can't hurt
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
            return '*****'
          end

          if #variable.value > 15 then
            return ' ' .. string.sub(variable.value, 1, 15) .. '... '
          end

          return ' ' .. variable.value
        end,
      }

      if dapui_ok then
        dap.listeners.before.attach.dapui_config = function()
          ui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
          ui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
          ui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          ui.close()
        end
      end
    end,
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'debug [b]reakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'debug [c]ontinue' },
      { '<leader>do', function() require('dap').step_over() end, desc = 'debug [o]ver' },
      { '<leader>dO', function() require('dap').step_out() end, desc = 'debug [O]ut' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'debug [i]nto' },
      { '<leader>dr', function() require('dap').repl_open() end, desc = 'debug [r]epl' },
      { '<leader>dq', function() require('dap').terminate() end, desc = 'debug [q]uit' },
      { '<leader>dx', function() require('dap').clear_breakpoints() end, desc = 'debug clear breakpoints' },
      { '<leader>de', function() require('dap').set_exception_breakpoints({ 'raised', 'uncaught' }) end, desc = 'debug [e]xceptions' },
      { '<leader>dv', function() require('dap').eval() end, mode = { 'n', 'v' }, desc = 'debug e[v]aluate' },
      {
        '<leader>du',
        function()
          local dapui_ok, ui = pcall(require, 'dapui')
          if dapui_ok then
            ui.toggle()
            return
          end

          vim.notify('nvim-dap-ui is unavailable', vim.log.levels.WARN)
        end,
        desc = 'debug [u]i',
      },
    },
  },
}
