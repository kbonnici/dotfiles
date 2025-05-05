local js_filetypes = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
}

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    -- "mxsdev/nvim-dap-vscode-js",
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
        },
      },
      -- mason-nvim-dap is loaded when nvim-dap loads
      config = function() end,
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
  },
  keys = {
    { "<leader>bB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>bb", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
    { "<leader>bc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
    -- { "<leader>ba", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
    { "<leader>bC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
    { "<leader>bg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
    { "<leader>bi", function() require("dap").step_into() end,                                            desc = "Step Into" },
    { "<leader>bj", function() require("dap").down() end,                                                 desc = "Down" },
    { "<leader>bk", function() require("dap").up() end,                                                   desc = "Up" },
    { "<leader>bl", function() require("dap").run_last() end,                                             desc = "Run Last" },
    { "<leader>bo", function() require("dap").step_out() end,                                             desc = "Step Out" },
    { "<leader>bO", function() require("dap").step_over() end,                                            desc = "Step Over" },
    { "<leader>bP", function() require("dap").pause() end,                                                desc = "Pause" },
    { "<leader>br", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
    { "<leader>bs", function() require("dap").session() end,                                              desc = "Session" },
    { "<leader>bt", function() require("dap").terminate() end,                                            desc = "Terminate" },
    { "<leader>bw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },

    { "<leader>bu", function() require("dapui").toggle({}) end,                                           desc = "Dap UI" },
    { "<leader>be", function() require("dapui").eval() end,                                               desc = "Eval",                   mode = { "n", "v" } },
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close({})
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close({})
    end

    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    -- setup dap config by VsCode launch.json file
    local vscode = require("dap.ext.vscode")
    local json = require("plenary.json")
    vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str))
    end

    -- require("dap-vscode-js").setup({
    --   -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
    --   debugger_path = "/Users/karl/js-debug",                                                      -- Path to vscode-js-debug installation.
    --   -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
    --   adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
    --   -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
    --   -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
    --   -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
    -- })

    if not dap.adapters["pwa-node"] then
      require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          -- 💀 Make sure to update this path to point to your installation
          args = { require("mason-registry").get_package("js-debug-adapter"):get_install_path()
          .. "/js-debug/src/dapDebugServer.js", "${port}" },
        },
      }
    end

    if not dap.adapters["node"] then
      dap.adapters["node"] = function(cb, config)
        if config.type == "node" then
          config.type = "pwa-node"
        end
        local nativeAdapter = dap.adapters["pwa-node"]
        if type(nativeAdapter) == "function" then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    vscode.type_to_filetypes["node"] = js_filetypes
    vscode.type_to_filetypes["pwa-node"] = js_filetypes

    for _, language in ipairs(js_filetypes) do
      if not dap.configurations[language] then
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Current File (pwa-node with deno)',
            cwd = vim.fn.getcwd(),
            runtimeArgs = { 'run', '--inspect-brk', '--allow-all', '${file}' },
            runtimeExecutable = 'deno',
            attachSimplePort = 9229,
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Test Current File (pwa-node with deno)',
            cwd = vim.fn.getcwd(),
            runtimeArgs = { 'test', '--inspect-brk', '--allow-all', '${file}' },
            runtimeExecutable = 'deno',
            attachSimplePort = 9229,
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end

    -- adapters (delete later)
    -- dap.adapters["node"] = {
    --   type = "server",
    --   host = "localhost",
    --   port = "${port}",
    --   executable = {
    --     command = "node",
    --     -- 💀 Make sure to update this path to point to your installation
    --     args = { require("mason-registry").get_package("js-debug-adapter"):get_install_path()
    --     .. "/js-debug/src/dapDebugServer.js", "${port}" },
    --   }
    -- }
  end
}
