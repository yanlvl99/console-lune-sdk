--!strict

local stdio = require("@lune/stdio")
local task = require("@lune/task")
local process = require("@lune/process")

local function stripAnsi(str: string): string
    return str:gsub("\27%[[%d;]*m", "")
end

local function getTerminalWidth(): number
    local width = 100 -- standard default fallback
    
    -- Try Windows 'mode con'
    local ok, result = pcall(function()
        local result = process.spawn("mode", {"con"})
        if result.ok then
            local cols = result.stdout:match("Columns:%s*(%d+)")
            return tonumber(cols)
        end
        return nil
    end)
    if ok and result then return math.max(60, math.min(result - 2, 150)) end
    
    -- Try Unix 'tput cols'
    local okUnix, resultUnix = pcall(function()
        local result = process.spawn("tput", {"cols"})
        if result.ok then
            return tonumber(result.stdout)
        end
        return nil
    end)
    if okUnix and resultUnix then return math.max(60, math.min(resultUnix - 2, 150)) end
    
    return width
end

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

local LANGUAGES = {
    lua = {
        keywords = {
            ["local"]=1, ["function"]=1, ["end"]=1, ["if"]=1, ["then"]=1, ["else"]=1, 
            ["elseif"]=1, ["for"]=1, ["while"]=1, ["do"]=1, ["repeat"]=1, ["until"]=1, 
            ["return"]=1, ["break"]=1, ["continue"]=1, ["in"]=1, ["not"]=1, ["and"]=1, 
            ["or"]=1, ["true"]=1, ["false"]=1, ["nil"]=1, ["type"]=1, ["export"]=1, 
            ["self"]=1, ["require"]=1, ["module"]=1
        },
        comment = "%-%-",
    },
    python = {
        keywords = {
            ["def"]=1, ["class"]=1, ["import"]=1, ["from"]=1, ["if"]=1, ["elif"]=1, 
            ["else"]=1, ["for"]=1, ["while"]=1, ["return"]=1, ["break"]=1, ["continue"]=1, 
            ["pass"]=1, ["try"]=1, ["except"]=1, ["finally"]=1, ["raise"]=1, ["with"]=1, 
            ["as"]=1, ["lambda"]=1, ["True"]=1, ["False"]=1, ["None"]=1, ["and"]=1, 
            ["or"]=1, ["not"]=1, ["in"]=1, ["is"]=1, ["print"]=1, ["global"]=1
        },
        comment = "#",
    },
    javascript = {
        keywords = {
            ["function"]=1, ["const"]=1, ["let"]=1, ["var"]=1, ["if"]=1, ["else"]=1, 
            ["for"]=1, ["while"]=1, ["return"]=1, ["break"]=1, ["continue"]=1, 
            ["switch"]=1, ["case"]=1, ["default"]=1, ["try"]=1, ["catch"]=1, 
            ["class"]=1, ["new"]=1, ["this"]=1, ["true"]=1, ["false"]=1, ["null"]=1, 
            ["undefined"]=1, ["async"]=1, ["await"]=1, ["import"]=1, ["export"]=1,
            ["console"]=1, ["extends"]=1, ["super"]=1, ["void"]=1, ["typeof"]=1
        },
        comment = "//",
    },
    bash = {
        keywords = {
            ["echo"]=1, ["if"]=1, ["then"]=1, ["else"]=1, ["fi"]=1, ["for"]=1, 
            ["in"]=1, ["do"]=1, ["done"]=1, ["while"]=1, ["case"]=1, ["esac"]=1, 
            ["function"]=1, ["return"]=1, ["exit"]=1, ["local"]=1, ["true"]=1, 
            ["false"]=1, ["sudo"]=1, ["apt"]=1, ["git"]=1, ["cd"]=1, ["ls"]=1,
            ["export"]=1, ["unset"]=1, ["source"]=1
        },
        comment = "#",
    },
    ruby = {
        keywords = {
            ["def"]=1, ["end"]=1, ["if"]=1, ["else"]=1, ["elsif"]=1, ["unless"]=1, 
            ["while"]=1, ["until"]=1, ["for"]=1, ["in"]=1, ["class"]=1, ["module"]=1, 
            ["require"]=1, ["include"]=1, ["return"]=1, ["true"]=1, ["false"]=1, 
            ["nil"]=1, ["self"]=1, ["super"]=1, ["yield"]=1, ["begin"]=1, ["rescue"]=1,
            ["ensure"]=1, ["raise"]=1, ["puts"]=1
        },
        comment = "#",
    },
    php = {
        keywords = {
            ["function"]=1, ["class"]=1, ["echo"]=1, ["if"]=1, ["else"]=1, ["elseif"]=1, 
            ["while"]=1, ["for"]=1, ["foreach"]=1, ["as"]=1, ["return"]=1, ["break"]=1, 
            ["continue"]=1, ["switch"]=1, ["case"]=1, ["default"]=1, ["try"]=1, 
            ["catch"]=1, ["public"]=1, ["private"]=1, ["protected"]=1, ["static"]=1,
            ["new"]=1, ["true"]=1, ["false"]=1, ["null"]=1, ["namespace"]=1, ["use"]=1
        },
        comment = "//",
    },
    java = {
        keywords = {
            ["class"]=1, ["public"]=1, ["private"]=1, ["protected"]=1, ["static"]=1, 
            ["final"]=1, ["void"]=1, ["int"]=1, ["double"]=1, ["boolean"]=1, ["if"]=1, 
            ["else"]=1, ["for"]=1, ["while"]=1, ["return"]=1, ["break"]=1, ["continue"]=1, 
            ["switch"]=1, ["case"]=1, ["default"]=1, ["try"]=1, ["catch"]=1, ["throw"]=1, 
            ["throws"]=1, ["new"]=1, ["this"]=1, ["super"]=1, ["import"]=1, ["package"]=1,
            ["true"]=1, ["false"]=1, ["null"]=1
        },
        comment = "//",
    },
    c = {
        keywords = {
            ["int"]=1, ["char"]=1, ["float"]=1, ["double"]=1, ["void"]=1, ["if"]=1, 
            ["else"]=1, ["for"]=1, ["while"]=1, ["do"]=1, ["return"]=1, ["break"]=1, 
            ["continue"]=1, ["switch"]=1, ["case"]=1, ["default"]=1, ["struct"]=1, 
            ["union"]=1, ["typedef"]=1, ["const"]=1, ["static"]=1, ["unsigned"]=1,
            ["long"]=1, ["short"]=1, ["include"]=1, ["define"]=1, ["NULL"]=1
        },
        comment = "//",
    },
    go = {
        keywords = {
            ["func"]=1, ["package"]=1, ["import"]=1, ["var"]=1, ["const"]=1, ["type"]=1, 
            ["struct"]=1, ["interface"]=1, ["map"]=1, ["if"]=1, ["else"]=1, ["for"]=1, 
            ["range"]=1, ["return"]=1, ["break"]=1, ["continue"]=1, ["switch"]=1, 
            ["case"]=1, ["default"]=1, ["go"]=1, ["defer"]=1, ["chan"]=1, ["select"]=1,
            ["true"]=1, ["false"]=1, ["nil"]=1
        },
        comment = "//",
    },
    rust = {
        keywords = {
            ["fn"]=1, ["let"]=1, ["mut"]=1, ["if"]=1, ["else"]=1, ["while"]=1, ["for"]=1, 
            ["in"]=1, ["loop"]=1, ["match"]=1, ["return"]=1, ["break"]=1, ["continue"]=1, 
            ["use"]=1, ["mod"]=1, ["pub"]=1, ["struct"]=1, ["enum"]=1, ["impl"]=1, 
            ["trait"]=1, ["type"]=1, ["const"]=1, ["static"]=1, ["unsafe"]=1, ["true"]=1, 
            ["false"]=1, ["self"]=1, ["super"]=1
        },
        comment = "//",
    },
    sql = {
        keywords = {
            ["SELECT"]=1, ["FROM"]=1, ["WHERE"]=1, ["INSERT"]=1, ["INTO"]=1, ["UPDATE"]=1, 
            ["DELETE"]=1, ["CREATE"]=1, ["TABLE"]=1, ["DROP"]=1, ["ALTER"]=1, ["INDEX"]=1, 
            ["JOIN"]=1, ["ON"]=1, ["AND"]=1, ["OR"]=1, ["NOT"]=1, ["NULL"]=1, ["AS"]=1, 
            ["ORDER"]=1, ["BY"]=1, ["GROUP"]=1, ["HAVING"]=1, ["LIMIT"]=1, ["VALUES"]=1
        },
        comment = "%-%-",
    }
}
-- Aliases
LANGUAGES.luau = LANGUAGES.lua
LANGUAGES.rb = LANGUAGES.ruby
LANGUAGES.py = LANGUAGES.python
LANGUAGES.js = LANGUAGES.javascript
LANGUAGES.ts = LANGUAGES.javascript
LANGUAGES.typescript = LANGUAGES.javascript
LANGUAGES.sh = LANGUAGES.bash
LANGUAGES.shell = LANGUAGES.bash
LANGUAGES.cpp = LANGUAGES.c -- reusing C keywords for C++ basics
LANGUAGES["c++"] = LANGUAGES.c
LANGUAGES.rs = LANGUAGES.rust
LANGUAGES.golang = LANGUAGES.go
LANGUAGES.json = LANGUAGES.js -- Reusing JS for basic highlighting (keys, strings, numbers)


function Console.highlightSyntax(line: string, language: string): string
    local langData = LANGUAGES[language]
    if not langData then
        return COLORS.white .. line .. COLORS.reset
    end
    
    local keywords = langData.keywords
    local commentPrefix = langData.comment.pattern or langData.comment

    local result = ""
    local remaining = line

    while #remaining > 0 do
        local nearestMatch = nil
        local nearestType = nil
        local matchStart, matchEnd = nil, nil

        -- 1. Comment
        local cS, cE = remaining:find(commentPrefix .. ".*$")
        if cS then nearestMatch = cS; nearestType = "comment"; matchStart, matchEnd = cS, cE end

        -- 2. Strings (double quotes)
        local sS, sE = remaining:find('"[^"]*"')
        if sS and (not nearestMatch or sS < nearestMatch) then nearestMatch = sS; nearestType = "string"; matchStart, matchEnd = sS, sE end

        -- 3. Strings (single quotes)
        local sqS, sqE = remaining:find("'[^']*'")
        if sqS and (not nearestMatch or sqS < nearestMatch) then nearestMatch = sqS; nearestType = "string"; matchStart, matchEnd = sqS, sqE end

        -- 4. Numbers
        local nS, nE = remaining:find("%d+%.?%d*")
        if nS and (not nearestMatch or nS < nearestMatch) then
             if nS == 1 or not remaining:sub(nS-1, nS-1):match("[%w_]") then nearestMatch = nS; nearestType = "number"; matchStart, matchEnd = nS, nE end
        end

        -- 5. Identifiers
        local iS, iE = remaining:find("[%a_][%w_]*")
        if iS and (not nearestMatch or iS < nearestMatch) then nearestMatch = iS; nearestType = "identifier"; matchStart, matchEnd = iS, iE end

        if not nearestMatch then
             result = result .. remaining:sub(1, 1)
             remaining = remaining:sub(2)
        else
             if (nearestMatch :: number) > 1 then result = result .. remaining:sub(1, (nearestMatch :: number) - 1) end
             local text = remaining:sub(matchStart :: number, matchEnd :: number)

             if nearestType == "comment" then result = result .. COLORS.brightBlack .. text .. COLORS.reset; remaining = "" 
             elseif nearestType == "string" then result = result .. COLORS.green .. text .. COLORS.reset; remaining = remaining:sub((matchEnd :: number) + 1)
             elseif nearestType == "number" then result = result .. COLORS.yellow .. text .. COLORS.reset; remaining = remaining:sub((matchEnd :: number) + 1)
             elseif nearestType == "identifier" then
                 if keywords[text] then result = result .. COLORS.magenta .. text .. COLORS.reset
                 elseif remaining:sub((matchEnd :: number) + 1, (matchEnd :: number) + 1) == "(" then result = result .. COLORS.cyan .. text .. COLORS.reset
                 else result = result .. text end
                 remaining = remaining:sub((matchEnd :: number) + 1)
             else result = result .. text; remaining = remaining:sub((matchEnd :: number) + 1) end
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
    -- Dynamic Terminal Width
    local termWidth = getTerminalWidth()
    
    local writer = {
        buffer = "",
        inCodeBlock = false,
        codeBlockLang = nil,
        tableBuffer = {},
        boxWidth = termWidth,
    } :: any 
    
    function writer:printTable()
        if #self.tableBuffer == 0 then return end
        local colWidths, cleanRows = {}, {}
        
        for _, rowRaw in ipairs(self.tableBuffer) do
            local cells = {}
            for cell in rowRaw:gmatch("|([^|]*)") do 
                table.insert(cells, cell:match("^%s*(.-)%s*$")) 
            end
            table.insert(cleanRows, cells)
            -- Use stripAnsi for width calculation just in case, though usually tables are plain text here
            for i, cell in ipairs(cells) do 
                colWidths[i] = math.max(colWidths[i] or 0, utf8.len(stripAnsi(cell)) or #cell) 
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
                local plainContent = stripAnsi(content)
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
                -- Closed box: └ + dashes + ┘
                -- Width logic: 1(└) + D + 1(┘) = Width. D = Width - 2.
                print(COLORS.brightBlack .. "└" .. string.rep("─", self.boxWidth - 2) .. "┘" .. COLORS.reset)
                self.codeBlockLang = nil
            else
                if #self.tableBuffer > 0 then self:printTable() end
                self.inCodeBlock = true
                self.codeBlockLang = if langMatch ~= "" then langMatch else "text"
                -- Header box: ┌─ lang ─...─┐
                -- Width = 1(┌) + 1(─) + 1( ) + N(lang) + 1( ) + D(dashes) + 1(┐) = N + 5 + D
                -- D = Width - N - 5
                local headerLen = utf8.len(self.codeBlockLang) or #self.codeBlockLang
                local dashLen = math.max(0, self.boxWidth - headerLen - 5)
                print(COLORS.brightBlack .. "┌─ " .. COLORS.cyan .. self.codeBlockLang .. " " .. COLORS.brightBlack .. " " .. string.rep("─", dashLen) .. "┐" .. COLORS.reset)
            end
            return
        end
        
        if self.inCodeBlock then
            -- Handle Wrapping with UTF8 awareness and stripAnsi
            local maxContentWidth = self.boxWidth - 4 -- │ + space + content + space + │
            local currentLine = line
            
            while true do
                local lineLen = utf8.len(currentLine) or #currentLine
                if lineLen == 0 and #currentLine == 0 then
                    if line == "" then
                        print(COLORS.brightBlack .. "│ " .. string.rep(" ", maxContentWidth) .. " │" .. COLORS.reset)
                    end
                    break
                end
                
                -- Split based on visual width
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
                
                local highlighted = Console.highlightSyntax(chunk, self.codeBlockLang or "text")
                -- We calculate padding based on RAW length of chunk, ignoring ANSI added by highlight
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
        if formatted:match("^#### ") then formatted = formatted:gsub("^#### (.*)", COLORS.cyan .. "    > %1" .. COLORS.reset)
        elseif formatted:match("^### ") then formatted = formatted:gsub("^### (.*)", COLORS.cyan .. STYLES.bold .. "  >> %1" .. COLORS.reset)
        elseif formatted:match("^## ") then formatted = formatted:gsub("^## (.*)", COLORS.yellow .. STYLES.bold .. "=== %1 ===" .. COLORS.reset)
        elseif formatted:match("^# ") then formatted = formatted:gsub("^# (.*)", COLORS.magenta .. STYLES.bold .. "### %1 ###" .. COLORS.reset) end
        
        formatted = formatted:gsub("%*%*(.-)%*%*", STYLES.bold .. "%1" .. COLORS.reset)
        formatted = formatted:gsub("%*(.-)%*", STYLES.italic .. "%1" .. COLORS.reset)
        formatted = formatted:gsub("`(.-)`", COLORS.yellow .. "%1" .. COLORS.reset)
        
        formatted = formatted:gsub("^%- ", COLORS.cyan .. "  • " .. COLORS.reset)
        formatted = formatted:gsub("^%* ", COLORS.cyan .. "  • " .. COLORS.reset) -- Added * support
        
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
    
    function writer:reset() self.buffer = ""; self.inCodeBlock = false; self.codeBlockLang = nil; self.tableBuffer = {} end
    return writer :: StreamWriter
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
