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
        local colWidths = {}
        local cleanRows = {}
        
        for _, rowRaw in ipairs(self.tableBuffer) do
            local cells = {}
            for cell in rowRaw:gmatch("|([^|]*)") do 
                table.insert(cells, cell:match("^%s*(.-)%s*$")) 
            end
            table.insert(cleanRows, cells)
            -- Use stripAnsi for width calculation
            for i, cell in ipairs(cells) do 
                colWidths[i] = math.max(colWidths[i] or 0, utf8.len(Utils.stripAnsi(cell)) or #cell) 
            end
        end
        
        local validRows = {}
        for _, cells in ipairs(cleanRows) do
             local isSep = true
             for _, c in ipairs(cells) do 
                 if c:gsub("%-", "") ~= "" and c ~= "" then 
                     isSep = false 
                     break 
                 end 
             end
             if not isSep then 
                 table.insert(validRows, cells) 
             end
        end
        if #validRows == 0 then self.tableBuffer = {}; return end

        local totalWidth = 1 
        for _, w in ipairs(colWidths) do totalWidth = totalWidth + w + 3 end
        
        print(COLORS.cyan .. "┌" .. string.rep("─", totalWidth - 2) .. "┐" .. COLORS.reset)
        for i, row in ipairs(validRows) do
            local line = COLORS.cyan .. "│" .. COLORS.reset
            for j = 1, #colWidths do
                local w, content = colWidths[j] or 0, row[j] or ""
                local plainContent = Utils.stripAnsi(content)
                local contentLen = utf8.len(plainContent) or #plainContent
                local padding = w - contentLen
                
                if i == 1 then content = STYLES.bold .. COLORS.yellow .. content .. COLORS.reset end
                line = line .. " " .. content .. string.rep(" ", padding) .. " " .. COLORS.cyan .. "│" .. COLORS.reset
            end
            print(line)
            if i == 1 then print(COLORS.cyan .. "├" .. string.rep("─", totalWidth - 2) .. "┤" .. COLORS.reset) end
        end
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
                    local headerLen = utf8.len(blockLang) or #blockLang
                    local dashLen = math.max(0, self.boxWidth - headerLen - 5)
                    print(COLORS.brightBlack .. "┌─ " .. COLORS.cyan .. blockLang .. " " .. COLORS.brightBlack .. " " .. string.rep("─", dashLen) .. "┐" .. COLORS.reset)
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
                local lineLen = utf8.len(currentLine) or #currentLine
                if lineLen == 0 and #currentLine == 0 then
                    if line == "" then
                        print(COLORS.brightBlack .. "│ " .. string.rep(" ", maxContentWidth) .. " │" .. COLORS.reset)
                    end
                    break
                end
                
                local splitIdx = 0
                local visualCount = 0
                for p, c in utf8.codes(currentLine) do
                     visualCount = visualCount + 1
                     if visualCount > maxContentWidth then break end
                     splitIdx = p + (utf8.charpattern:match(currentLine, p) and #utf8.charpattern:match(currentLine, p) or 1) - 1
                end
                if splitIdx == 0 then splitIdx = #currentLine end
                
                local chunk = currentLine:sub(1, splitIdx)
                currentLine = currentLine:sub(splitIdx + 1)
                
                if chunk == "" then break end
                
                local highlighted = if self.config.syntaxHighlighting then Highlighter.highlight(chunk, self.codeBlockLang or "text") else chunk
                local chunkVisibleLen = utf8.len(chunk) or #chunk
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
