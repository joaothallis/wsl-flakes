{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  programs = {
    git = {
      enable = true;
      settings = {
        commit = {
          verbose = true;
        };
        user.name = "João Thallis";
        user.email = "joaothallis.developer@gmail.com";
      };
      ignores = [
        ".direnv"
        ".envrc"
        "**/.claude/settings.local.json"
      ];
    };
    gh = {
      enable = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    bash.enable = true;
    bash.shellAliases = {
      gs = "git status";
      gd = "git diff";
      gl = "git pull --prune";
      gp = "git push";
      glog = "git log --oneline";
      gc = "git commit --patch";
      gca = "git commit --patch --amend";
      mf = "mix format";
      mc = "mix credo --strict";
      md = "mix dialyzer";
    };
    tmux = {
      enable = true;
      escapeTime = 10;
      focusEvents = true;
      terminal = "screen-256color";
      extraConfig = ''
                  set-option -a terminal-features 'xterm-256color:RGB'
        	  '';
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      extraLuaConfig = ''
                vim.opt.number = true

                local o = vim.o

                o.clipboard = "unnamedplus"

        	vim.opt.numberwidth = 1

		vim.diagnostic.config({
		  virtual_text = true,
		})
		
		local fmt_group = vim.api.nvim_create_augroup('autoformat_cmds', {clear = true})

		local function setup_autoformat(event)
		  local id = vim.tbl_get(event, 'data', 'client_id')
		  local client = id and vim.lsp.get_client_by_id(id)
		  if client == nil then
		    return
		  end

		  vim.api.nvim_clear_autocmds({group = fmt_group, buffer = event.buf})

		  local buf_format = function(e)
		    vim.lsp.buf.format({
		      bufnr = e.buf,
		      async = false,
		      timeout_ms = 10000,
		    })
		  end

		  vim.api.nvim_create_autocmd('BufWritePre', {
		    buffer = event.buf,
		    group = fmt_group,
		    desc = 'Format current buffer',
		    callback = buf_format,
		  })
		end

		vim.api.nvim_create_autocmd('LspAttach', {
		  desc = 'Setup format on save',
		  callback = setup_autoformat,
		})

		-- time it takes to trigger the `CursorHold` event
		vim.opt.updatetime = 400

		local function highlight_symbol(event)
		  local id = vim.tbl_get(event, 'data', 'client_id')
		  local client = id and vim.lsp.get_client_by_id(id)
		  if client == nil or not client.supports_method('textDocument/documentHighlight') then
		    return
		  end

		  local group = vim.api.nvim_create_augroup('highlight_symbol', {clear = false})

		  vim.api.nvim_clear_autocmds({buffer = event.buf, group = group})

		  vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
		    group = group,
		    buffer = event.buf,
		    callback = vim.lsp.buf.document_highlight,
		  })

		  vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
		    group = group,
		    buffer = event.buf,
		    callback = vim.lsp.buf.clear_references,
		  })
		end

		vim.api.nvim_create_autocmd('LspAttach', {
		  desc = 'Setup highlight symbol',
		  callback = highlight_symbol,
		})

		vim.api.nvim_create_autocmd('LspAttach', {
		  desc = 'Enable inlay hints',
		  callback = function(event)
		    local id = vim.tbl_get(event, 'data', 'client_id')
		    local client = id and vim.lsp.get_client_by_id(id)
		    if client == nil or not client.supports_method('textDocument/inlayHint') then
		      return
		    end

		    vim.lsp.inlay_hint.enable(true, {bufnr = event.buf})
		  end,
		})
      '';

      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            		vim.lsp.config('expert', {
            		  cmd = { '/home/nixos/.local/bin/expert', '--stdio' },
            		  root_markers = { 'mix.exs', '.git' },
            		  filetypes = { 'elixir', 'eelixir', 'heex' },
            		})

            		vim.lsp.enable 'expert'

			vim.lsp.enable('nixd')
          '';
        }
        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            local blink = require("blink.cmp")
            blink.setup({})
                        	      '';
        }
        {
          plugin = fidget-nvim;
          type = "lua";
          config = ''
            require("fidget").setup { }
                        	      '';
        }
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            	        require'nvim-treesitter.configs'.setup {
                    highlight = {enable = true}
                }
            	      '';
        }
        vim-elixir
        {
          plugin = elixir-tools-nvim;
          type = "lua";
          config = ''
            require("elixir").setup({
              nextls = {enable = false},
              elixirls = {enable = false},
              projectionist = {enable = true},
            })
          '';
        }
        vim-projectionist
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
                         local telescope = require("telescope")
                            telescope.setup({
                                defaults = {
                                    vimgrep_arguments = {
                                        "rg", "--color=never", "--no-heading", "--with-filename",
                                        "--line-number", "--column", "--smart-case", "--hidden",
                                        "--glob=!.git"
                                    }
                                }
                            })
                            local builtin = require("telescope.builtin")
                            vim.keymap.set("n", "<leader>ff", builtin.git_files, {})
                            vim.keymap.set('n', '<leader>fg', builtin.live_grep,
                                           {desc = 'Telescope live grep'})
            		vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
                        	  '';
        }
        vimux
        {
          plugin = vim-test;
          config = ''
                        	  let g:test#echo_command = 0

                        if exists('$TMUX')
                          let g:test#preserve_screen = 1
                          let g:test#strategy = 'vimux'
            	    else
            	      let g:test#strategy = 'neovim_sticky'
                        endif

                        nmap <silent> <leader>t :TestNearest<CR>
                        nmap <silent> <leader>T :TestFile<CR>
                        nmap <silent> <leader>a :TestSuite<CR>
                        nmap <silent> <leader>l :TestLast<CR>
                        nmap <silent> <leader>g :TestVisit<CR>
                        	  '';
        }
        vim-fugitive
        {
          plugin = gitlinker-nvim;
          type = "lua";
          config = "require'gitlinker'.setup()";
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            	  require('gitsigns').setup{
            	    on_attach = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, l, r, opts)
                  opts = opts or {}
                  opts.buffer = bufnr
                  vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                  if vim.wo.diff then
                    vim.cmd.normal({']c', bang = true})
                  else
                    gitsigns.nav_hunk('next')
                  end
                end)

                map('n', '[c', function()
                  if vim.wo.diff then
                    vim.cmd.normal({'[c', bang = true})
                  else
                    gitsigns.nav_hunk('prev')
                  end
                end)
              end
            	  }
            	  '';
        }

        file-line
      ];
    };
  };

  home.packages = [
    pkgs.vim-full
    pkgs.ripgrep
    pkgs.tig
    pkgs.nodePackages.nodejs
    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
