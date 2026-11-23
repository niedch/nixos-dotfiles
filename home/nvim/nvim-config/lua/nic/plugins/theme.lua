return {
  {
    "duxlabs-dev/base46",
    lazy = false,
    priority = 1000,
    opts = {
      hl_add = {
        -- Main window & borders
        SnacksPicker = { bg = "darker_black", fg = "white" },
        SnacksPickerBorder = { fg = "line", bg = "darker_black" },
        SnacksPickerBox = { bg = "darker_black" },
        SnacksPickerBoxBorder = { fg = "line", bg = "darker_black" },
        SnacksPickerBoxTitle = { fg = "black", bg = "nord_blue", bold = true },

        -- Prompt / Input window
        SnacksPickerInput = { bg = "black2", fg = "white" },
        SnacksPickerInputBorder = { fg = "line", bg = "black2" },
        SnacksPickerInputTitle = { fg = "black", bg = "red", bold = true },
        SnacksPickerPrompt = { fg = "red", bg = "black2" },
        SnacksPickerInputSearch = { fg = "green" },

        -- List & Selection
        SnacksPickerList = { bg = "darker_black" },
        SnacksPickerListBorder = { fg = "line", bg = "darker_black" },
        SnacksPickerListTitle = { fg = "black", bg = "nord_blue", bold = true },
        SnacksPickerListCursorLine = { bg = "black2" },
        SnacksPickerCursorLine = { bg = "black2" },
        SnacksPickerMatch = { fg = "blue", bold = true },
        SnacksPickerSearch = { fg = "black", bg = "sun" },
        SnacksPickerSelected = { fg = "green", bold = true },
        SnacksPickerUnselected = { fg = "light_grey" },
        SnacksPickerTotals = { fg = "light_grey" },
        SnacksPickerSpinner = { fg = "green" },
        SnacksPickerToggle = { fg = "teal" },

        -- Preview window
        SnacksPickerPreview = { bg = "darker_black" },
        SnacksPickerPreviewBorder = { fg = "line", bg = "darker_black" },
        SnacksPickerPreviewTitle = { fg = "black", bg = "green", bold = true },
        SnacksPickerPreviewCursorLine = { bg = "black2" },

        -- Explorer & File tree
        SnacksPickerDirectory = { fg = "folder_bg", bold = true },
        SnacksPickerFile = { fg = "white" },
        SnacksPickerDir = { fg = "light_grey" },
        SnacksPickerTree = { fg = "line" },
        SnacksPickerPathIgnored = { fg = "light_grey" },
        SnacksPickerPathHidden = { fg = "grey_fg" },
        SnacksPickerLink = { fg = "teal" },
        SnacksPickerLinkBroken = { fg = "red" },

        -- Git Status (Explorer & Picker items)
        SnacksPickerGitStatus = { fg = "purple" },
        SnacksPickerGitStatusAdded = { fg = "green" },
        SnacksPickerGitStatusModified = { fg = "yellow" },
        SnacksPickerGitStatusDeleted = { fg = "red" },
        SnacksPickerGitStatusRenamed = { fg = "purple" },
        SnacksPickerGitStatusCopied = { fg = "teal" },
        SnacksPickerGitStatusUntracked = { fg = "baby_pink" },
        SnacksPickerGitStatusIgnored = { fg = "light_grey" },
        SnacksPickerGitStatusUnmerged = { fg = "red", bold = true },
        SnacksPickerGitStatusStaged = { fg = "vibrant_green" },

        -- Git metadata (Commits, Branches, Logs)
        SnacksPickerGitBranch = { fg = "purple", bold = true },
        SnacksPickerGitBranchCurrent = { fg = "green", bold = true },
        SnacksPickerGitCommit = { fg = "orange" },
        SnacksPickerGitAuthor = { fg = "nord_blue" },
        SnacksPickerGitDate = { fg = "light_grey" },
        SnacksPickerGitMsg = { fg = "white" },
        SnacksPickerGitType = { fg = "blue" },
        SnacksPickerGitScope = { fg = "pink" },
        SnacksPickerGitBreaking = { fg = "red", bold = true },
        SnacksPickerGitIssue = { fg = "baby_pink" },
        SnacksPickerGitDetached = { fg = "yellow" },

        -- UI Elements & Diagnostics
        SnacksPickerDelim = { fg = "grey" },
        SnacksPickerRow = { fg = "sun" },
        SnacksPickerCol = { fg = "light_grey" },
        SnacksPickerIdx = { fg = "baby_pink" },
        SnacksPickerSpecial = { fg = "purple" },
        SnacksPickerDesc = { fg = "light_grey" },
        SnacksPickerComment = { fg = "light_grey" },
        SnacksPickerRule = { fg = "line" },
        SnacksPickerPickWin = { fg = "black", bg = "sun", bold = true },
        SnacksPickerPickWinCurrent = { fg = "black", bg = "green", bold = true },
      },
    },
    config = function(_, opts)
      require("base46").setup(opts)
      -- Try loading the DMS-generated colorscheme; fallback to base46-kanagawa if not yet generated
      if not pcall(vim.cmd.colorscheme, "dms") then
        pcall(vim.cmd.colorscheme, "base46-kanagawa")
      end
    end,
  },
}
