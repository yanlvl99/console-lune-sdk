--!strict
local process = require("@lune/process")

local Utils = {}

Utils.COLORS = {
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
    
    -- Cores customizadas RGB (8-bit) para syntax highlighting
    purple = "\27[38;5;141m",        -- Roxo suave para keywords
    orange = "\27[38;5;214m",        -- Laranja vibrante para números
    pink = "\27[38;5;211m",          -- Rosa para strings
    teal = "\27[38;5;80m",           -- Teal para funções
    lime = "\27[38;5;155m",          -- Verde limão para tipos
    gold = "\27[38;5;220m",          -- Dourado para constantes
    sky = "\27[38;5;117m",           -- Azul céu para classes
    coral = "\27[38;5;209m",         -- Coral para operadores
    gray = "\27[38;5;245m",          -- Cinza para comentários
}

Utils.BG_COLORS = {
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

Utils.STYLES = {
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

function Utils.stripAnsi(str: string): string
    return str:gsub("\27%[[%d;]*m", "")
end

function Utils.visualWidth(str: string): number
    -- Strip ANSI codes first
    local clean = Utils.stripAnsi(str)
    
    local width = 0
    for pos, codepoint in utf8.codes(clean) do
        -- Emoji ranges (common emoji blocks)
        -- Most emojis are width 2 in terminals
        if (codepoint >= 0x1F300 and codepoint <= 0x1F9FF) or  -- Misc Symbols and Pictographs, Emoticons, etc
           (codepoint >= 0x2600 and codepoint <= 0x27BF) or    -- Misc symbols
           (codepoint >= 0x1F600 and codepoint <= 0x1F64F) or  -- Emoticons
           (codepoint >= 0x1F680 and codepoint <= 0x1F6FF) or  -- Transport and Map
           (codepoint >= 0x2700 and codepoint <= 0x27BF) or    -- Dingbats
           (codepoint >= 0xFE00 and codepoint <= 0xFE0F) or    -- Variation Selectors
           (codepoint >= 0x1F900 and codepoint <= 0x1F9FF) or  -- Supplemental Symbols
           (codepoint >= 0x1FA70 and codepoint <= 0x1FAFF) or  -- Symbols and Pictographs Extended-A
           (codepoint >= 0x2300 and codepoint <= 0x23FF) or    -- Miscellaneous Technical
           (codepoint >= 0x2B50 and codepoint <= 0x2B55) or    -- Stars and geometric shapes  
           (codepoint >= 0x3200 and codepoint <= 0x32FF) or    -- Enclosed CJK Letters and Months
           (codepoint == 0x2714) or (codepoint == 0x2716) or   -- Check marks
           (codepoint == 0x25A0) or (codepoint == 0x25A1) or   -- Squares
           (codepoint >= 0x2190 and codepoint <= 0x21FF) or    -- Arrows
           (codepoint >= 0x3000 and codepoint <= 0x303F) or    -- CJK Symbols
           (codepoint >= 0x3040 and codepoint <= 0x309F) or    -- Hiragana
           (codepoint >= 0x30A0 and codepoint <= 0x30FF) or    -- Katakana
           (codepoint >= 0x4E00 and codepoint <= 0x9FFF) or    -- CJK Unified Ideographs
           (codepoint >= 0xAC00 and codepoint <= 0xD7AF) then  -- Hangul Syllables
            width = width + 2
        else
            width = width + 1
        end
    end
    
    return width
end

function Utils.getTerminalWidth(): number
    local width = 100
    
    local ok, result = pcall(function()
        local proc: any = process
        local res = proc.spawn("mode", {"con"})
        if res.ok then
            local cols = res.stdout:match("Columns:%s*(%d+)")
            return tonumber(cols)
        end
        return nil
    end)
    if ok and result then return math.max(60, math.min(result - 2, 150)) end
    
    local okUnix, resultUnix = pcall(function()
        local proc: any = process
        local res = proc.spawn("tput", {"cols"})
        if res.ok then
            return tonumber(res.stdout)
        end
        return nil
    end)
    if okUnix and resultUnix then return math.max(60, math.min(resultUnix - 2, 150)) end
    
    return width
end

return Utils
