return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "InsertEnter",
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible",
      n_completions = 1, -- ponytail: 1 completion = less local compute; bump if you want alternates
      context_window = 512,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM", -- dummy, ollama ignores it
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:0.5b-base",
          optional = {
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          -- built-in accept disabled; handled below so <Right> still moves cursor when no suggestion
          accept = nil,
          accept_line = "<S-Right>",
          accept_n_lines = nil,
          prev = "<M-[>",
          next = "<M-]>",
          dismiss = "<Esc>",
        },
      },
    })

    -- <Right> accepts suggestion only when one is shown, else normal cursor move
    vim.keymap.set("i", "<Right>", function()
      local vt = require("minuet.virtualtext").action
      if vt.is_visible() then
        vt.accept()
      else
        return "<Right>"
      end
    end, { expr = true, desc = "minuet accept or move right" })
  end,
}
