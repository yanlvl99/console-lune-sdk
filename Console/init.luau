--!strict

local stdio = require("@lune/stdio")
local task = require("@lune/task")

export type Color = "black" | "red" | "green" | "yellow" | "blue" | "magenta" | "cyan" | "white" | "reset"
export type Style = "bold" | "dim" | "italic" | "underline" | "blink" | "reverse" | "hidden" | "strikethrough"

local COLORS = {
    black = "\27[30m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m",
    reset = "\27[0m",
    
    brightBlack = "\27[90m",
    brightRed = "\27[91m",
    brightGreen = "\27[92m",
    brightYellow = "\27[93m",
    brightBlue = "\27[94m",
    brightMagenta = "\27[95m",
    brightCyan = "\27[96m",
    brightWhite = "\27[97m",
}

local BG_COLORS = {
    black = "\27[40m",
    red = "\27[41m",
    green = "\27[42m",
    yellow = "\27[43m",
    blue = "\27[44m",
    magenta = "\27[45m",
    cyan = "\27[46m",
    white = "\27[47m",
    
    brightBlack = "\27[100m",
    brightRed = "\27[101m",
    brightGreen = "\27[102m",
    brightYellow = "\27[103m",
    brightBlue = "\27[104m",
    brightMagenta = "\27[105m",
    brightCyan = "\27[106m",
    brightWhite = "\27[107m",
}

local STYLES = {
    bold = "\27[1m",
    dim = "\27[2m",
    italic = "\27[3m",
    underline = "\27[4m",
    blink = "\27[5m",
    reverse = "\27[7m",
    hidden = "\27[8m",
    strikethrough = "\27[9m",
    reset = "\27[0m",
}

local Console = {}

function Console.color(color: string): string
    return (COLORS :: any)[color] or COLORS.reset
end

function Console.bg(color: string): string
    return (BG_COLORS :: any)[color] or ""
end

function Console.style(style: string): string
    return (STYLES :: any)[style] or ""
end

function Console.reset(): string
    return COLORS.reset
end

function Console.format(text: string, color: string?, style: string?, bgColor: string?): string
    local result = ""
    
    if style then
        result = result .. Console.style(style)
    end
    
    if bgColor then
        result = result .. Console.bg(bgColor)
    end
    
    if color then
        result = result .. Console.color(color)
    end
    
    result = result .. text .. COLORS.reset
    
    return result
end

function Console.red(text: string): string
    return COLORS.red .. text .. COLORS.reset
end

function Console.green(text: string): string
    return COLORS.green .. text .. COLORS.reset
end

function Console.yellow(text: string): string
    return COLORS.yellow .. text .. COLORS.reset
end

function Console.blue(text: string): string
    return COLORS.blue .. text .. COLORS.reset
end

function Console.magenta(text: string): string
    return COLORS.magenta .. text .. COLORS.reset
end

function Console.cyan(text: string): string
    return COLORS.cyan .. text .. COLORS.reset
end

function Console.white(text: string): string
    return COLORS.white .. text .. COLORS.reset
end

function Console.gray(text: string): string
    return COLORS.brightBlack .. text .. COLORS.reset
end

function Console.bold(text: string): string
    return STYLES.bold .. text .. COLORS.reset
end

function Console.italic(text: string): string
    return STYLES.italic .. text .. COLORS.reset
end

function Console.underline(text: string): string
    return STYLES.underline .. text .. COLORS.reset
end

function Console.dim(text: string): string
    return STYLES.dim .. text .. COLORS.reset
end

function Console.strikethrough(text: string): string
    return STYLES.strikethrough .. text .. COLORS.reset
end

function Console.print(...: any)
    local args = { ... }
    local output = {}
    
    for i, arg in ipairs(args) do
        output[i] = tostring(arg)
    end
    
    print(table.concat(output, "\t"))
end

function Console.write(text: string)
    stdio.write(text)
end

function Console.writeln(text: string)
    stdio.write(text .. "\n")
end

function Console.success(message: string)
    print(COLORS.green .. "[OK] " .. message .. COLORS.reset)
end

function Console.error(message: string)
    print(COLORS.red .. "[X] " .. message .. COLORS.reset)
end

function Console.warn(message: string)
    print(COLORS.yellow .. "[!] " .. message .. COLORS.reset)
end

function Console.info(message: string)
    print(COLORS.cyan .. "[i] " .. message .. COLORS.reset)
end

function Console.debug(message: string)
    print(COLORS.brightBlack .. "[?] " .. message .. COLORS.reset)
end

function Console.log(message: string)
    print(COLORS.white .. message .. COLORS.reset)
end

function Console.header(title: string, char: string?)
    local divider = string.rep(char or "═", 60)
    print(COLORS.cyan .. divider .. COLORS.reset)
    print(COLORS.cyan .. STYLES.bold .. "  " .. title .. COLORS.reset)
    print(COLORS.cyan .. divider .. COLORS.reset)
end

function Console.divider(char: string?, length: number?)
    local len = length or 60
    local c = char or "─"
    print(COLORS.brightBlack .. string.rep(c, len) .. COLORS.reset)
end

function Console.newline(count: number?)
    for _ = 1, (count or 1) do
        print("")
    end
end

function Console.table(data: { [string]: any }, title: string?)
    if title then
        print(COLORS.cyan .. STYLES.bold .. title .. COLORS.reset)
        Console.divider()
    end
    
    for key, value in pairs(data) do
        local keyStr = COLORS.yellow .. tostring(key) .. COLORS.reset
        local valueStr = COLORS.white .. tostring(value) .. COLORS.reset
        print("  " .. keyStr .. ": " .. valueStr)
    end
end

function Console.list(items: { string }, bullet: string?)
    local b = bullet or "•"
    for _, item in ipairs(items) do
        print(COLORS.cyan .. "  " .. b .. " " .. COLORS.reset .. item)
    end
end

function Console.numbered(items: { string })
    for i, item in ipairs(items) do
        local num = COLORS.yellow .. tostring(i) .. "." .. COLORS.reset
        print("  " .. num .. " " .. item)
    end
end

function Console.progress(current: number, total: number, width: number?)
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

function Console.spinner(frames: { string }?, interval: number?): () -> ()
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

function Console.box(text: string, padding: number?)
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

function Console.code(text: string, language: string?)
    local lang = language or "lua"
    print(COLORS.brightBlack .. "```" .. lang .. COLORS.reset)
    
    for line in text:gmatch("[^\n]+") do
        local highlighted = Console.highlightSyntax(line, lang)
        print("  " .. highlighted)
    end
    
    print(COLORS.brightBlack .. "```" .. COLORS.reset)
end

function Console.highlightSyntax(line: string, language: string): string
    if language ~= "lua" and language ~= "luau" then
        return COLORS.white .. line .. COLORS.reset
    end

    local result = ""
    local remaining = line
    
    local keywords = {
        ["local"] = true, ["function"] = true, ["end"] = true, ["if"] = true, 
        ["then"] = true, ["else"] = true, ["elseif"] = true, ["for"] = true, 
        ["while"] = true, ["do"] = true, ["repeat"] = true, ["until"] = true, 
        ["return"] = true, ["break"] = true, ["continue"] = true, ["in"] = true, 
        ["not"] = true, ["and"] = true, ["or"] = true, ["true"] = true, 
        ["false"] = true, ["nil"] = true, ["type"] = true, ["export"] = true, 
        ["self"] = true
    }

    while #remaining > 0 do
        -- Check for comments
        local commentStart = remaining:find("%-%-")
        if commentStart then
            -- Check if comment is not inside a string (simplistic check)
            -- A proper parser is needed for perfect accuracy, but this improves basic rendering
             -- For now, just prioritizing comment if it appears
             -- If we want to be smarter, we should check what comes first: comment, string, or keyword
        end

        -- Find potential tokens: comment, string, number, identifier
        local nearestMatch = nil
        local nearestType = nil
        local matchStart, matchEnd = nil, nil

        -- 1. Comment
        local cS, cE = remaining:find("%-%-.*$")
        if cS then
             nearestMatch = cS
             nearestType = "comment"
             matchStart, matchEnd = cS, cE
        end

        -- 2. Strings (double quotes)
        local sS, sE = remaining:find('"[^"]*"')
        if sS and (not nearestMatch or sS < nearestMatch) then
            nearestMatch = sS
            nearestType = "string"
            matchStart, matchEnd = sS, sE
        end

        -- 3. Strings (single quotes)
        local sqS, sqE = remaining:find("'[^']*'")
        if sqS and (not nearestMatch or sqS < nearestMatch) then
            nearestMatch = sqS
            nearestType = "string"
            matchStart, matchEnd = sqS, sqE
        end

        -- 4. Numbers
        local nS, nE = remaining:find("%d+%.?%d*")
        if nS and (not nearestMatch or nS < nearestMatch) then
             -- Verify it's not part of an identifier (naive)
             if nS == 1 or not remaining:sub(nS-1, nS-1):match("[%w_]") then
                 nearestMatch = nS
                 nearestType = "number"
                 matchStart, matchEnd = nS, nE
             end
        end

        -- 5. Identifiers (keywords or functions)
        local iS, iE = remaining:find("[%a_][%w_]*")
        if iS and (not nearestMatch or iS < nearestMatch) then
            nearestMatch = iS
            nearestType = "identifier"
            matchStart, matchEnd = iS, iE
        end

        -- 6. Operators/Punctuation (generic catch to move forward if nothing else matches)
        if not nearestMatch then
             result = result .. remaining:sub(1, 1)
             remaining = remaining:sub(2)
        else
             -- Append text before match
             if (nearestMatch :: number) > 1 then
                 result = result .. remaining:sub(1, (nearestMatch :: number) - 1)
             end

             local text = remaining:sub(matchStart :: number, matchEnd :: number)

             if nearestType == "comment" then
                 result = result .. COLORS.brightBlack .. text .. COLORS.reset
                 remaining = "" -- Comment consumes rest of line
             elseif nearestType == "string" then
                 result = result .. COLORS.green .. text .. COLORS.reset
                 remaining = remaining:sub((matchEnd :: number) + 1)
             elseif nearestType == "number" then
                 result = result .. COLORS.yellow .. text .. COLORS.reset
                 remaining = remaining:sub((matchEnd :: number) + 1)
             elseif nearestType == "identifier" then
                 if keywords[text] then
                     result = result .. COLORS.magenta .. text .. COLORS.reset
                 elseif remaining:sub((matchEnd :: number) + 1, (matchEnd :: number) + 1) == "(" then
                     -- Function call
                     result = result .. COLORS.cyan .. text .. COLORS.reset
                 else
                     -- Normal variable/text
                     result = result .. text
                 end
                 remaining = remaining:sub((matchEnd :: number) + 1)
             else
                 -- Should not happen with logic above, but fallback
                 result = result .. text
                 remaining = remaining:sub((matchEnd :: number) + 1)
             end
        end
    end

    return result
end


function Console.markdown(text: string)
    local result = text
    
    result = result:gsub("#### (.-)\n", COLORS.cyan .. "    > %1\n" .. COLORS.reset)
    result = result:gsub("### (.-)\n", COLORS.cyan .. STYLES.bold .. "  >> %1\n" .. COLORS.reset)
    result = result:gsub("## (.-)\n", COLORS.yellow .. STYLES.bold .. "=== %1 ===\n" .. COLORS.reset)
    result = result:gsub("# (.-)\n", COLORS.magenta .. STYLES.bold .. "### %1 ###\n" .. COLORS.reset)
    
    result = result:gsub("%*%*(.-)%*%*", STYLES.bold .. "%1" .. COLORS.reset)
    
    result = result:gsub("%*(.-)%*", STYLES.italic .. "%1" .. COLORS.reset)
    
    result = result:gsub("`(.-)`", COLORS.yellow .. "%1" .. COLORS.reset)
    
    result = result:gsub("^%- ", COLORS.cyan .. "  • " .. COLORS.reset)
    result = result:gsub("\n%- ", "\n" .. COLORS.cyan .. "  • " .. COLORS.reset)
    
    result = result:gsub("^(%d+)%. ", COLORS.yellow .. "  %1. " .. COLORS.reset)
    result = result:gsub("\n(%d+)%. ", "\n" .. COLORS.yellow .. "  %1. " .. COLORS.reset)
    
    local lines = {}
    for line in (result .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    
    local formattedLines = {}
    local inTable = false
    local _tableWidth = 0
    
    for i, line in ipairs(lines) do
        local isTableRow = line:match("^|.*|$")
        local isSeparator = line:match("^|[%-:|]+|$")
        
        if isTableRow then
            if not inTable then
                inTable = true
                table.insert(formattedLines, COLORS.brightBlack .. string.rep("─", 60) .. COLORS.reset)
            end
            
            if isSeparator then
                table.insert(formattedLines, COLORS.brightBlack .. string.rep("─", 60) .. COLORS.reset)
            else
                local cells = {}
                for cell in line:gmatch("|([^|]+)") do
                    local trimmed = cell:match("^%s*(.-)%s*$") or cell
                    table.insert(cells, trimmed)
                end
                
                local formattedRow = COLORS.cyan .. "│" .. COLORS.reset
                for j, cell in ipairs(cells) do
                    if i == 1 or (i == 2 and lines[1]:match("^|.*|$")) then
                        formattedRow = formattedRow .. " " .. STYLES.bold .. COLORS.yellow .. cell .. COLORS.reset .. " " .. COLORS.cyan .. "│" .. COLORS.reset
                    else
                        formattedRow = formattedRow .. " " .. cell .. " " .. COLORS.cyan .. "│" .. COLORS.reset
                    end
                end
                table.insert(formattedLines, formattedRow)
            end
        else
            if inTable then
                inTable = false
                table.insert(formattedLines, COLORS.brightBlack .. string.rep("─", 60) .. COLORS.reset)
            end
            table.insert(formattedLines, line)
        end
    end
    
    print(table.concat(formattedLines, "\n"))
end


function Console.gradient(text: string, startColor: string, endColor: string): string
    local colors = {
        red = { 255, 0, 0 },
        green = { 0, 255, 0 },
        blue = { 0, 0, 255 },
        yellow = { 255, 255, 0 },
        magenta = { 255, 0, 255 },
        cyan = { 0, 255, 255 },
        white = { 255, 255, 255 },
        orange = { 255, 165, 0 },
        pink = { 255, 105, 180 },
        purple = { 128, 0, 128 },
    }
    
    local start = (colors :: any)[startColor] or colors.white
    local finish = (colors :: any)[endColor] or colors.white
    
    local result = ""
    local len = #text
    
    for i = 1, len do
        local char = text:sub(i, i)
        local ratio = (i - 1) / math.max(len - 1, 1)
        
        local r = math.floor(start[1] + (finish[1] - start[1]) * ratio)
        local g = math.floor(start[2] + (finish[2] - start[2]) * ratio)
        local b = math.floor(start[3] + (finish[3] - start[3]) * ratio)
        
        result = result .. string.format("\27[38;2;%d;%d;%dm%s", r, g, b, char)
    end
    
    return result .. COLORS.reset
end

function Console.rainbow(text: string): string
    local rainbowColors = {
        { 255, 0, 0 },
        { 255, 127, 0 },
        { 255, 255, 0 },
        { 0, 255, 0 },
        { 0, 0, 255 },
        { 75, 0, 130 },
        { 148, 0, 211 },
    }
    
    local result = ""
    local len = #text
    
    for i = 1, len do
        local char = text:sub(i, i)
        local colorIndex = ((i - 1) % #rainbowColors) + 1
        local color = rainbowColors[colorIndex]
        
        result = result .. string.format("\27[38;2;%d;%d;%dm%s", color[1], color[2], color[3], char)
    end
    
    return result .. COLORS.reset
end

function Console.rgb(text: string, r: number, g: number, b: number): string
    return string.format("\27[38;2;%d;%d;%dm%s%s", r, g, b, text, COLORS.reset)
end

function Console.bgRgb(text: string, r: number, g: number, b: number): string
    return string.format("\27[48;2;%d;%d;%dm%s%s", r, g, b, text, COLORS.reset)
end

function Console.clear()
    stdio.write("\27[2J\27[H")
end

function Console.clearLine()
    stdio.write("\27[2K\r")
end

function Console.moveCursor(row: number, col: number)
    stdio.write(string.format("\27[%d;%dH", row, col))
end

function Console.saveCursor()
    stdio.write("\27[s")
end

function Console.restoreCursor()
    stdio.write("\27[u")
end

function Console.hideCursor()
    stdio.write("\27[?25l")
end

function Console.showCursor()
    stdio.write("\27[?25h")
end

export type StreamWriter = {
    buffer: string,
    
    write: (self: StreamWriter, chunk: string) -> (),
    flush: (self: StreamWriter) -> (),
    reset: (self: StreamWriter) -> (),
}

function Console.createStreamWriter(): StreamWriter
    local writer: StreamWriter = {
        buffer = "",
    } :: StreamWriter
    
    function writer:write(chunk: string)
        stdio.write(chunk)
    end
    
    function writer:flush()
    end
    
    function writer:reset()
        self.buffer = ""
    end
    
    return writer
end

function Console.streamWrite(chunk: string, writer: StreamWriter?)
    if writer then
        writer:write(chunk)
    else
        stdio.write(chunk)
    end
end

function Console.autoFormat(text: string): string
    local result = text
    
    local codeBlockPattern = "```(%w*)[\r\n](.-)[\r\n]```"
    result = result:gsub(codeBlockPattern, COLORS.brightBlack .. "```%1\n%2\n```" .. COLORS.reset)
    
    result = result:gsub("### (.-)\n", COLORS.cyan .. STYLES.bold .. "### %1\n" .. COLORS.reset)
    result = result:gsub("## (.-)\n", COLORS.cyan .. STYLES.bold .. "## %1\n" .. COLORS.reset)
    result = result:gsub("# (.-)\n", COLORS.cyan .. STYLES.bold .. "# %1\n" .. COLORS.reset)
    
    result = result:gsub("%*%*(.-)%*%*", STYLES.bold .. "%1" .. COLORS.reset)
    result = result:gsub("%*(.-)%*", STYLES.italic .. "%1" .. COLORS.reset)
    result = result:gsub("`(.-)`", COLORS.yellow .. "%1" .. COLORS.reset)
    
    result = result:gsub("^%- ", COLORS.cyan .. "• " .. COLORS.reset)
    result = result:gsub("\n%- ", "\n" .. COLORS.cyan .. "• " .. COLORS.reset)
    
    result = result:gsub("^(%d+)%. ", COLORS.yellow .. "%1. " .. COLORS.reset)
    result = result:gsub("\n(%d+)%. ", "\n" .. COLORS.yellow .. "%1. " .. COLORS.reset)
    
    return result
end

function Console.input(label: string, default: string?): string
    return stdio.prompt("text", label, default)
end

function Console.confirm(label: string, default: boolean?): boolean
    return stdio.prompt("confirm", label, default)
end

function Console.select(label: string, options: { string }, default: number?): number
    return stdio.prompt("select", label, options, default)
end

function Console.multiselect(label: string, options: { string }, default: { number }?): { number }
    return stdio.prompt("multiselect", label, options, default)
end

return Console
