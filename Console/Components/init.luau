--!strict
local stdio = require("@lune/stdio")
local task = require("@lune/task")
local Utils = require("@Utils")
local Highlighter = require("@Highlighter")

local COLORS = Utils.COLORS
local STYLES = Utils.STYLES

local Components = {}

function Components.header(title: string, char: string?)
    local divider = string.rep(char or "═", 60)
    print(COLORS.cyan .. divider .. COLORS.reset)
    print(COLORS.cyan .. STYLES.bold .. "  " .. title .. COLORS.reset)
    print(COLORS.cyan .. divider .. COLORS.reset)
end

function Components.divider(char: string?, length: number?)
    local len = length or 60
    local c = char or "─"
    print(COLORS.brightBlack .. string.rep(c, len) .. COLORS.reset)
end

function Components.table(data: { [string]: any }, title: string?)
    if title then
        print(COLORS.cyan .. STYLES.bold .. title .. COLORS.reset)
        Components.divider()
    end
    
    for key, value in pairs(data) do
        local keyStr = COLORS.yellow .. tostring(key) .. COLORS.reset
        local valueStr = COLORS.white .. tostring(value) .. COLORS.reset
        print("  " .. keyStr .. ": " .. valueStr)
    end
end

function Components.list(items: { string }, bullet: string?)
    local b = bullet or "•"
    for _, item in ipairs(items) do
        print(COLORS.cyan .. "  " .. b .. " " .. COLORS.reset .. item)
    end
end

function Components.numbered(items: { string })
    for i, item in ipairs(items) do
        local num = COLORS.yellow .. tostring(i) .. "." .. COLORS.reset
        print("  " .. num .. " " .. item)
    end
end

function Components.progress(current: number, total: number, width: number?)
    local w = width or 40
    local percentage = current / total
    local filled = math.floor(percentage * w)
    local empty = w - filled
    
    local bar = COLORS.green .. string.rep("█", filled) .. 
                COLORS.brightBlack .. string.rep("░", empty) .. 
                COLORS.reset
    
    local percentText = COLORS.yellow .. string.format("%3d%%", math.floor(percentage * 100)) .. COLORS.reset
    
    stdio.write("\r[" .. bar .. "] " .. percentText)
    
    if current >= total then
        print("")
    end
end

function Components.spinner(frames: { string }?, interval: number?): () -> ()
    local spinnerFrames = frames or { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    local frameInterval = interval or 0.1
    local currentFrame = 1
    local running = true
    
    task.spawn(function()
        while running do
            stdio.write("\r" .. COLORS.cyan .. spinnerFrames[currentFrame] .. COLORS.reset .. " ")
            currentFrame = (currentFrame % #spinnerFrames) + 1
            task.wait(frameInterval)
        end
    end)
    
    return function()
        running = false
        stdio.write("\r  \r")
    end
end

function Components.box(text: string, padding: number?)
    local pad = padding or 1
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    local maxWidth = 0
    for _, line in ipairs(lines) do
        maxWidth = math.max(maxWidth, #line)
    end
    
    local totalWidth = maxWidth + (pad * 2)
    
    print(COLORS.cyan .. "┌" .. string.rep("─", totalWidth) .. "┐" .. COLORS.reset)
    
    for _ = 1, pad do
        print(COLORS.cyan .. "│" .. COLORS.reset .. string.rep(" ", totalWidth) .. COLORS.cyan .. "│" .. COLORS.reset)
    end
    
    for _, line in ipairs(lines) do
        local paddedLine = string.rep(" ", pad) .. line .. string.rep(" ", maxWidth - #line + pad)
        print(COLORS.cyan .. "│" .. COLORS.reset .. paddedLine .. COLORS.cyan .. "│" .. COLORS.reset)
    end
    
    for _ = 1, pad do
        print(COLORS.cyan .. "│" .. COLORS.reset .. string.rep(" ", totalWidth) .. COLORS.cyan .. "│" .. COLORS.reset)
    end
    
    print(COLORS.cyan .. "└" .. string.rep("─", totalWidth) .. "┘" .. COLORS.reset)
end

function Components.code(text: string, language: string?)
    local lang = language or "lua"
    local lines = {}
    for line in text:gmatch("[^\n]+") do table.insert(lines, line) end
    
    local termWidth = Utils.getTerminalWidth()
    local maxLineLen = 0
    for _, l in ipairs(lines) do maxLineLen = math.max(maxLineLen, Utils.visualWidth(l)) end
    
    local boxWidth = math.min(termWidth, math.max(60, maxLineLen + 6))
    
    -- Header: "┌─ " + lang + " " + "─"*dashLen + "┐"
    -- Total width = 1 + 1 + 1 + langLen + 1 + dashLen + 1 = boxWidth
    local langLen = Utils.visualWidth(lang)
    local dashLen = math.max(0, boxWidth - langLen - 5)
    print(COLORS.brightBlack .. "┌─ " .. COLORS.cyan .. lang .. COLORS.brightBlack .. " " .. string.rep("─", dashLen) .. "┐" .. COLORS.reset)
    
    for _, line in ipairs(lines) do
         local highlighted = Highlighter.highlight(line, lang)
         local visibleLen = Utils.visualWidth(line)
         local padding = math.max(0, boxWidth - visibleLen - 4)
         print(COLORS.brightBlack .. "│ " .. COLORS.reset .. highlighted .. string.rep(" ", padding) .. COLORS.brightBlack .. " │" .. COLORS.reset)
    end
    
    print(COLORS.brightBlack .. "└" .. string.rep("─", boxWidth - 2) .. "┘" .. COLORS.reset)
end

function Components.apiTable(headers: {string}, rows: {{string}}, title: string?)
    -- Calculate column widths using visual width (handles emojis correctly)
    local colWidths = {}
    for i, header in ipairs(headers) do
        colWidths[i] = Utils.visualWidth(Utils.stripAnsi(header))
    end
    
    for _, row in ipairs(rows) do
        for i, cell in ipairs(row) do
            local cleanCell = Utils.stripAnsi(cell)
            colWidths[i] = math.max(colWidths[i] or 0, Utils.visualWidth(cleanCell))
        end
    end
    
    -- Add padding
    for i = 1, #colWidths do
        colWidths[i] = colWidths[i] + 2
    end
    
    -- Calculate total width
    local totalWidth = 0
    for _, width in ipairs(colWidths) do
        totalWidth = totalWidth + width + 1
    end
    totalWidth = totalWidth + 1
    
    -- Print title if provided
    if title then
        print(COLORS.cyan .. STYLES.bold .. "\n" .. title .. COLORS.reset)
    end
    
    -- Top border
    local topBorder = COLORS.cyan .. "┌"
    for i, width in ipairs(colWidths) do
        topBorder = topBorder .. string.rep("─", width)
        if i < #colWidths then
            topBorder = topBorder .. "┬"
        end
    end
    topBorder = topBorder .. "┐" .. COLORS.reset
    print(topBorder)
    
    -- Header row
    local headerRow = COLORS.cyan .. "│" .. COLORS.reset
    for i, header in ipairs(headers) do
        local cleanHeader = Utils.stripAnsi(header)
        local padding = colWidths[i] - Utils.visualWidth(cleanHeader)
        local leftPad = math.floor(padding / 2)
        local rightPad = padding - leftPad
        headerRow = headerRow .. COLORS.yellow .. STYLES.bold .. 
                    string.rep(" ", leftPad) .. header .. string.rep(" ", rightPad) .. 
                    COLORS.reset .. COLORS.cyan .. "│" .. COLORS.reset
    end
    print(headerRow)
    
    -- Header separator
    local separator = COLORS.cyan .. "├"
    for i, width in ipairs(colWidths) do
        separator = separator .. string.rep("─", width)
        if i < #colWidths then
            separator = separator .. "┼"
        end
    end
    separator = separator .. "┤" .. COLORS.reset
    print(separator)
    
    -- Data rows
    for _, row in ipairs(rows) do
        local rowStr = COLORS.cyan .. "│" .. COLORS.reset
        for i, cell in ipairs(row) do
            local cleanCell = Utils.stripAnsi(cell)
            local padding = colWidths[i] - Utils.visualWidth(cleanCell)
            rowStr = rowStr .. " " .. cell .. string.rep(" ", padding - 1) .. COLORS.cyan .. "│" .. COLORS.reset
        end
        print(rowStr)
    end
    
    -- Bottom border
    local bottomBorder = COLORS.cyan .. "└"
    for i, width in ipairs(colWidths) do
        bottomBorder = bottomBorder .. string.rep("─", width)
        if i < #colWidths then
            bottomBorder = bottomBorder .. "┴"
        end
    end
    bottomBorder = bottomBorder .. "┘" .. COLORS.reset
    print(bottomBorder)
end

function Components.markdown(text: string)
    
    -- Helper to render markdown table
    local function renderTable(lines: {string}): string
        if #lines < 3 then return table.concat(lines, "\n") end
        
        -- Helper to strip markdown syntax (for size calculation)
        local function stripMarkdown(content: string): string
            local stripped = content
            -- Remove backticks
            stripped = stripped:gsub("`([^`]+)`", "%1")
            -- Remove bold
            stripped = stripped:gsub("%*%*(.-)%*%*", "%1")
            -- Remove italic
            stripped = stripped:gsub("%*(.-)%*", "%1")
            return stripped
        end
        
        -- Helper to format cell content (apply markdown formatting)
        local function formatCell(content: string): string
            local formatted = content
            -- Apply backticks (code) - yellow color
            formatted = formatted:gsub("`([^`]+)`", COLORS.yellow .. "%1" .. COLORS.reset)
            -- Apply bold
            formatted = formatted:gsub("%*%*(.-)%*%*", STYLES.bold .. "%1" .. COLORS.reset)
            -- Apply italic
            formatted = formatted:gsub("%*(.-)%*", STYLES.italic .. "%1" .. COLORS.reset)
            return formatted
        end
        
        -- Parse header
        local headers = {}
        local headersRaw = {}
        -- Remove leading/trailing pipes and split
        local headerLine = lines[1]:gsub("^%s*|%s*", ""):gsub("%s*|%s*$", "")
        for cell in headerLine:gmatch("([^|]+)") do
            local trimmed = cell:match("^%s*(.-)%s*$")
            if trimmed and #trimmed > 0 then
                table.insert(headersRaw, stripMarkdown(trimmed))
                table.insert(headers, formatCell(trimmed))
            end
        end
        
        if #headers == 0 then return table.concat(lines, "\n") end
        
        -- Parse data rows (skip separator line at index 2)
        local rows = {}
        local rowsRaw = {}
        for i = 3, #lines do
            -- Skip separator lines (contains only |, -, :, and whitespace)
            if lines[i]:match("^[|%s%-:]+$") then
                -- Skip this line
            else
                local row = {}
                local rowRaw = {}
                -- Remove leading/trailing pipes and split
                local rowLine = lines[i]:gsub("^%s*|%s*", ""):gsub("%s*|%s*$", "")
                for cell in rowLine:gmatch("([^|]+)") do
                    local trimmed = cell:match("^%s*(.-)%s*$")
                    if trimmed then
                        table.insert(rowRaw, stripMarkdown(trimmed))
                        table.insert(row, formatCell(trimmed))
                    end
                end
                if #row > 0 and #row == #headers then
                    table.insert(rowsRaw, rowRaw)
                    table.insert(rows, row)
                end
            end
        end

        
        -- Calculate column widths based on RAW (unformatted) content
        local colWidths = {}
        for i, header in ipairs(headersRaw) do
            colWidths[i] = Utils.visualWidth(header)
        end
        
        for _, row in ipairs(rowsRaw) do
            for i, cell in ipairs(row) do
                colWidths[i] = math.max(colWidths[i] or 0, Utils.visualWidth(cell))
            end
        end
        
        -- Add padding
        for i = 1, #colWidths do
            colWidths[i] = colWidths[i] + 2
        end
        
        -- Build table
        local output = {}
        
        -- Top border
        local topBorder = COLORS.cyan .. "┌"
        for i, width in ipairs(colWidths) do
            topBorder = topBorder .. string.rep("─", width)
            if i < #colWidths then
                topBorder = topBorder .. "┬"
            end
        end
        topBorder = topBorder .. "┐" .. COLORS.reset
        table.insert(output, topBorder)
        
        -- Header row
        local headerRow = COLORS.cyan .. "│" .. COLORS.reset
        for i, header in ipairs(headers) do
            local rawHeader = headersRaw[i]
            local padding = colWidths[i] - Utils.visualWidth(rawHeader)
            local leftPad = math.floor(padding / 2)
            local rightPad = padding - leftPad
            headerRow = headerRow .. COLORS.yellow .. STYLES.bold .. 
                        string.rep(" ", leftPad) .. header .. string.rep(" ", rightPad) .. 
                        COLORS.reset .. COLORS.cyan .. "│" .. COLORS.reset
        end
        table.insert(output, headerRow)
        
        -- Header separator
        local separator = COLORS.cyan .. "├"
        for i, width in ipairs(colWidths) do
            separator = separator .. string.rep("─", width)
            if i < #colWidths then
                separator = separator .. "┼"
            end
        end
        separator = separator .. "┤" .. COLORS.reset
        table.insert(output, separator)
        
        -- Data rows
        for rowIdx, row in ipairs(rows) do
            local rowStr = COLORS.cyan .. "│" .. COLORS.reset
            for i, cell in ipairs(row) do
                local rawCell = rowsRaw[rowIdx][i]
                local padding = colWidths[i] - Utils.visualWidth(rawCell)
                rowStr = rowStr .. " " .. cell .. string.rep(" ", padding - 1) .. COLORS.cyan .. "│" .. COLORS.reset
            end
            table.insert(output, rowStr)
        end
        
        -- Bottom border
        local bottomBorder = COLORS.cyan .. "└"
        for i, width in ipairs(colWidths) do
            bottomBorder = bottomBorder .. string.rep("─", width)
            if i < #colWidths then
                bottomBorder = bottomBorder .. "┴"
            end
        end
        bottomBorder = bottomBorder .. "┘" .. COLORS.reset
        table.insert(output, bottomBorder)
        
        return table.concat(output, "\n")
    end
    
    -- Process text line by line and detect tables
    local currentTable: {string}? = nil
    local result = {}
    
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        if line:match("^%s*|") then
            -- Table line
            if not currentTable then
                currentTable = {} :: {string}
            end
            table.insert(currentTable :: {string}, line)
        else
            -- Not a table line
            if currentTable and #currentTable >= 3 then
                -- We have a complete table, render it
                table.insert(result, renderTable(currentTable))
            elseif currentTable then
                -- Incomplete table, add as regular lines
                for _, tline in ipairs(currentTable) do
                    table.insert(result, tline)
                end
            end
            currentTable = nil
            table.insert(result, line)
        end
    end
    
    -- Handle last table if exists
    if currentTable and #currentTable >= 3 then
        table.insert(result, renderTable(currentTable))
    elseif currentTable then
        for _, tline in ipairs(currentTable) do
            table.insert(result, tline)
        end
    end
    
    local processedText = table.concat(result, "\n")
    
    -- Process other markdown
    processedText = processedText:gsub("#### (.-)\\n", COLORS.cyan .. "    > %1\\n" .. COLORS.reset)
    processedText = processedText:gsub("### (.-)\\n", COLORS.cyan .. STYLES.bold .. "  >> %1\\n" .. COLORS.reset)
    processedText = processedText:gsub("## (.-)\\n", COLORS.yellow .. STYLES.bold .. "=== %1 ===\\n" .. COLORS.reset)
    processedText = processedText:gsub("# (.-)\\n", COLORS.magenta .. STYLES.bold .. "### %1 ###\\n" .. COLORS.reset)
    processedText = processedText:gsub("%*%*(.-)%*%*", STYLES.bold .. "%1" .. COLORS.reset)
    processedText = processedText:gsub("%*(.-)%*", STYLES.italic .. "%1" .. COLORS.reset)
    processedText = processedText:gsub("`(.-)`", COLORS.yellow .. "%1" .. COLORS.reset)
    processedText = processedText:gsub("^%- ", COLORS.cyan .. "  • " .. COLORS.reset)
    processedText = processedText:gsub("\\n%- ", "\\n" .. COLORS.cyan .. "  • " .. COLORS.reset)
    processedText = processedText:gsub("^(%d+)%. ", COLORS.yellow .. "  %1. " .. COLORS.reset)
    processedText = processedText:gsub("\\n(%d+)%. ", "\\n" .. COLORS.yellow .. "  %1. " .. COLORS.reset)
    
    print(processedText)
end

return Components
