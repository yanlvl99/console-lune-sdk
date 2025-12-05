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
