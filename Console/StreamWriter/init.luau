--!strict
local Utils = require("@Utils")
local Highlighter = require("@Highlighter")
local COLORS = Utils.COLORS
local STYLES = Utils.STYLES

export type StreamConfig = {
    boxWidth: number?,
    boxedCode: boolean?,
    syntaxHighlighting: boolean?,
}

export type StreamWriter = {
    buffer: string,
    inCodeBlock: boolean,
    codeBlockLang: string?,
    tableBuffer: {string},
    boxWidth: number,
    config: {
        boxedCode: boolean,
        syntaxHighlighting: boolean
    },
    
    printTable: (self: StreamWriter) -> (),
    processLine: (self: StreamWriter, line: string) -> (),
    write: (self: StreamWriter, chunk: string) -> (),
    flush: (self: StreamWriter) -> (),
    reset: (self: StreamWriter) -> (),
}

local StreamWriter = {}

function StreamWriter.new(config: StreamConfig?): StreamWriter
    local cfg: StreamConfig | { boxWidth: number, boxedCode: boolean, syntaxHighlighting: boolean } = config or {}
    local termWidth = if cfg.boxWidth then cfg.boxWidth else Utils.getTerminalWidth()
    
    local writer = {
        buffer = "",
        inCodeBlock = false,
        codeBlockLang = nil,
        tableBuffer = {},
        boxWidth = termWidth,
        
        config = {
            boxedCode = if cfg.boxedCode ~= nil then cfg.boxedCode else true,
            syntaxHighlighting = if cfg.syntaxHighlighting ~= nil then cfg.syntaxHighlighting else true
        }
    } :: any
    
    function writer:printTable()
        if #self.tableBuffer == 0 then return end
        
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
        
        -- Helper to format cell content
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
        
        local colWidths = {}
        local cleanRows = {}
        local rawRows = {}
        
        for _, rowRaw in ipairs(self.tableBuffer) do
            local cells = {}
            local rawCells = {}
            -- Remove leading/trailing pipes and split
            local rowLine = rowRaw:gsub("^%s*|%s*", ""):gsub("%s*|%s*$", "")
            for cell in rowLine:gmatch("([^|]+)") do 
                local trimmed = cell:match("^%s*(.-)%s*$")
                if trimmed then
                    table.insert(rawCells, stripMarkdown(trimmed))
                    table.insert(cells, formatCell(trimmed))
                end
            end
            table.insert(rawRows, rawCells)
            table.insert(cleanRows, cells)
            
            -- Calculate widths based on RAW (unformatted) content
            for i, cell in ipairs(rawCells) do 
                colWidths[i] = math.max(colWidths[i] or 0, Utils.visualWidth(cell))
            end
        end
        
        -- Filter out separator rows
        local validRows = {}
        local validRawRows = {}
        for idx, cells in ipairs(rawRows) do
             local isSep = true
             for _, c in ipairs(cells) do 
                 -- Check if cell contains only -, :, and whitespace
                 if c:gsub("[%-:%s]", "") ~= "" then 
                     isSep = false 
                     break 
                 end 
             end
             if not isSep then 
                 table.insert(validRawRows, cells)
                 table.insert(validRows, cleanRows[idx]) 
             end
        end
        if #validRows == 0 then self.tableBuffer = {}; return end

        local totalWidth = 1 
        for _, w in ipairs(colWidths) do totalWidth = totalWidth + w + 3 end
        
        -- Top border
        print(COLORS.cyan .. "┌" .. string.rep("─", totalWidth - 2) .. "┐" .. COLORS.reset)
        
        for i, row in ipairs(validRows) do
            local line = COLORS.cyan .. "│" .. COLORS.reset
            for j = 1, #colWidths do
                local w = colWidths[j] or 0
                local content = row[j] or ""
                local rawContent = validRawRows[i][j] or ""
                local contentLen = Utils.visualWidth(rawContent)
                local padding = w - contentLen
                
                if i == 1 then 
                    -- Header row - add bold/yellow
                    content = STYLES.bold .. COLORS.yellow .. content .. COLORS.reset 
                end
                line = line .. " " .. content .. string.rep(" ", padding) .. " " .. COLORS.cyan .. "│" .. COLORS.reset
            end
            print(line)
            
            -- Header separator after first row
            if i == 1 then 
                local sep = COLORS.cyan .. "├"
                for j, w in ipairs(colWidths) do
                    sep = sep .. string.rep("─", w + 2)
                    if j < #colWidths then
                        sep = sep .. "┼"
                    end
                end
                sep = sep .. "┤" .. COLORS.reset
                print(sep)
            end
        end
        
        -- Bottom border
        print(COLORS.cyan .. "└" .. string.rep("─", totalWidth - 2) .. "┘" .. COLORS.reset)
        self.tableBuffer = {}
    end
    
    function writer:processLine(line: string)
        local langMatch = line:match("^%s*```(%w*)%s*$")
        if langMatch then 
             if self.inCodeBlock then
                self.inCodeBlock = false
                if self.config.boxedCode then
                    print(COLORS.brightBlack .. "└" .. string.rep("─", self.boxWidth - 2) .. "┘" .. COLORS.reset)
                end
                self.codeBlockLang = nil
            else
                if #self.tableBuffer > 0 then self:printTable() end
                self.inCodeBlock = true
                self.codeBlockLang = if langMatch ~= "" then langMatch else "text"
                
                if self.config.boxedCode then
                    -- Header box logic
                    local blockLang = self.codeBlockLang :: string
                    local langLen = Utils.visualWidth(blockLang)
                    local dashLen = math.max(0, self.boxWidth - langLen - 5)
                    print(COLORS.brightBlack .. "┌─ " .. COLORS.cyan .. blockLang .. COLORS.brightBlack .. " " .. string.rep("─", dashLen) .. "┐" .. COLORS.reset)
                else
                    -- No box
                end
            end
            return
        end
        
        if self.inCodeBlock then
            local currentLine = line
            local maxContentWidth = self.boxWidth - 4
            
            -- If boxing is off, just print highlighted?
            if not self.config.boxedCode then
                 local highlighted = if self.config.syntaxHighlighting then Highlighter.highlight(currentLine, self.codeBlockLang or "text") else currentLine
                 print(highlighted)
                 return
            end

            while true do
                if currentLine == "" then
                    if line == "" then
                        print(COLORS.brightBlack .. "│ " .. string.rep(" ", maxContentWidth) .. " │" .. COLORS.reset)
                    end
                    break
                end
                
                -- Calculate visual width and split if needed
                local splitIdx = 0
                local visualWidth = 0
                local pos = 1
                
                while pos <= #currentLine do
                    local charLen = 1
                    local byte = string.byte(currentLine, pos)
                    
                    -- UTF-8 multi-byte character detection
                    if byte >= 240 then charLen = 4
                    elseif byte >= 224 then charLen = 3
                    elseif byte >= 192 then charLen = 2
                    end
                    
                    local char = currentLine:sub(pos, pos + charLen - 1)
                    local charVisWidth = Utils.visualWidth(char)
                    
                    if visualWidth + charVisWidth > maxContentWidth then
                        break
                    end
                    
                    visualWidth = visualWidth + charVisWidth
                    splitIdx = pos + charLen - 1
                    pos = pos + charLen
                end
                
                if splitIdx == 0 then splitIdx = #currentLine end
                
                local chunk = currentLine:sub(1, splitIdx)
                currentLine = currentLine:sub(splitIdx + 1)
                
                if chunk == "" then break end
                
                local highlighted = if self.config.syntaxHighlighting then Highlighter.highlight(chunk, self.codeBlockLang or "text") else chunk
                local chunkVisibleLen = Utils.visualWidth(chunk)
                local padding = math.max(0, maxContentWidth - chunkVisibleLen)
                
                print(COLORS.brightBlack .. "│ " .. COLORS.reset .. highlighted .. string.rep(" ", padding) .. COLORS.brightBlack .. " │" .. COLORS.reset)
                
                if currentLine == "" then break end
            end
            return
        end
        
        if line:match("^%s*|.*|%s*$") then table.insert(self.tableBuffer, line); return
        else if #self.tableBuffer > 0 then self:printTable() end end
        
        local formatted = line
        -- Markdown formatting
        if formatted:match("^#### ") then formatted = formatted:gsub("^#### (.*)", COLORS.cyan .. "    > %1" .. COLORS.reset)
        elseif formatted:match("^### ") then formatted = formatted:gsub("^### (.*)", COLORS.cyan .. STYLES.bold .. "  >> %1" .. COLORS.reset)
        elseif formatted:match("^## ") then formatted = formatted:gsub("^## (.*)", COLORS.yellow .. STYLES.bold .. "=== %1 ===" .. COLORS.reset)
        elseif formatted:match("^# ") then formatted = formatted:gsub("^# (.*)", COLORS.magenta .. STYLES.bold .. "### %1 ###" .. COLORS.reset) end
        
        formatted = formatted:gsub("%*%*(.-)%*%*", STYLES.bold .. "%1" .. COLORS.reset)
        formatted = formatted:gsub("%*(.-)%*", STYLES.italic .. "%1" .. COLORS.reset)
        formatted = formatted:gsub("`(.-)`", COLORS.yellow .. "%1" .. COLORS.reset)
        
        formatted = formatted:gsub("^%- ", COLORS.cyan .. "  • " .. COLORS.reset)
        formatted = formatted:gsub("^%* ", COLORS.cyan .. "  • " .. COLORS.reset)
        
        formatted = formatted:gsub("^(%d+)%. ", COLORS.yellow .. "  %1. " .. COLORS.reset)
        if formatted:match("^%-%-%-%s*$") or formatted:match("^%*%*%*%s*$") then formatted = COLORS.brightBlack .. string.rep("─", self.boxWidth) .. COLORS.reset end
        print(formatted)
    end
    
    function writer:write(chunk: string)
        self.buffer = self.buffer .. chunk
        while true do
            local lineEnd = self.buffer:find("\n")
            if not lineEnd then break end
            local line = self.buffer:sub(1, lineEnd - 1)
            if line:sub(-1) == "\r" then line = line:sub(1, -2) end
            self.buffer = self.buffer:sub(lineEnd + 1)
            self:processLine(line)
        end
    end
    
    function writer:flush()
        if #self.buffer > 0 then self:processLine(self.buffer); self.buffer = "" end
        if #self.tableBuffer > 0 then self:printTable() end
    end
    
    function writer:reset() 
        self.buffer = ""
        self.inCodeBlock = false
        self.codeBlockLang = nil
        self.tableBuffer = {} 
    end
    
    return writer
end

return StreamWriter
