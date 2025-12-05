local Utils = require("@Utils")
local Highlighter = require("@Highlighter")
local Components = require("@Components")
local StreamWriter = require("@StreamWriter")

local stdio = require("@lune/stdio")

local Console = {}

-- Export Types
export type Color = "black" | "red" | "green" | "yellow" | "blue" | "magenta" | "cyan" | "white" | "reset"
export type Style = "bold" | "dim" | "italic" | "underline" | "blink" | "reverse" | "hidden" | "strikethrough"
export type StreamWriter = StreamWriter.StreamWriter

-- Re-export Utils
Console.color = function(c: string) return (Utils.COLORS :: any)[c] or Utils.COLORS.reset end
Console.bg = function(c: string) return (Utils.BG_COLORS :: any)[c] or "" end
Console.style = function(s: string) return (Utils.STYLES :: any)[s] or "" end
Console.reset = function() return Utils.COLORS.reset end
Console.clear = function() stdio.write("\27[2J\27[H") end
Console.clearLine = function() stdio.write("\27[2K\r") end
Console.moveCursor = function(r: number, c: number) stdio.write(string.format("\27[%d;%dH", r, c)) end
Console.saveCursor = function() stdio.write("\27[s") end
Console.restoreCursor = function() stdio.write("\27[u") end
Console.hideCursor = function() stdio.write("\27[?25l") end
Console.showCursor = function() stdio.write("\27[?25h") end

-- Formatting Helpers
function Console.format(text: string, color: string?, style: string?, bgColor: string?): string
    local result = ""
    if style then result = result .. Console.style(style) end
    if bgColor then result = result .. Console.bg(bgColor) end
    if color then result = result .. Console.color(color) end
    result = result .. text .. Utils.COLORS.reset
    return result
end

-- Colors Shortcuts
local colors = { "red", "green", "yellow", "blue", "magenta", "cyan", "white", "gray" }
for _, c in ipairs(colors) do
     local colorKey = if c == "gray" then "brightBlack" else c
     ;(Console :: any)[c] = function(text: string) return Utils.COLORS[colorKey] .. text .. Utils.COLORS.reset end
end

-- Style Shortcuts
local styles = { "bold", "italic", "underline", "dim", "strikethrough" }
for _, s in ipairs(styles) do
    (Console :: any)[s] = function(text: string) return Utils.STYLES[s] .. text .. Utils.COLORS.reset end
end

-- Basic I/O
function Console.print(...)
    local args = { ... }
    local output = {}
    for i, arg in ipairs(args) do output[i] = tostring(arg) end
    print(table.concat(output, "\t"))
end
Console.write = function(t: string) stdio.write(t) end
Console.writeln = function(t: string) stdio.write(t .. "\n") end

-- Logging
Console.success = function(msg: string) print(Utils.COLORS.green .. "[OK] " .. msg .. Utils.COLORS.reset) end
Console.error = function(msg: string) print(Utils.COLORS.red .. "[X] " .. msg .. Utils.COLORS.reset) end
Console.warn = function(msg: string) print(Utils.COLORS.yellow .. "[!] " .. msg .. Utils.COLORS.reset) end
Console.info = function(msg: string) print(Utils.COLORS.cyan .. "[i] " .. msg .. Utils.COLORS.reset) end
Console.debug = function(msg: string) print(Utils.COLORS.brightBlack .. "[?] " .. msg .. Utils.COLORS.reset) end
Console.log = function(msg: string) print(Utils.COLORS.white .. msg .. Utils.COLORS.reset) end

-- Configuration
local defaultConfig = {
    boxedCode = true,
    syntaxHighlighting = true,
    boxWidth = nil :: number?,
}

function Console.configure(config: { boxedCode: boolean?, syntaxHighlighting: boolean?, boxWidth: number? })
    if config.boxedCode ~= nil then defaultConfig.boxedCode = config.boxedCode end
    if config.syntaxHighlighting ~= nil then defaultConfig.syntaxHighlighting = config.syntaxHighlighting end
    if config.boxWidth ~= nil then defaultConfig.boxWidth = config.boxWidth end
end

-- Re-export Components
Console.header = Components.header
Console.divider = Components.divider
Console.table = Components.table
Console.list = Components.list
Console.numbered = Components.numbered
Console.progress = Components.progress
Console.spinner = Components.spinner
Console.box = Components.box
Console.markdown = Components.markdown

-- Wrapped Components (respecting config)
function Console.code(text: string, language: string?)
    if defaultConfig.boxedCode then
        Components.code(text, language)
    else
        local lang = language or "text"
        if defaultConfig.syntaxHighlighting then
            print(Highlighter.highlight(text, lang))
        else
            print(text)
        end
    end
end

-- Highlighter
Console.highlightSyntax = Highlighter.highlight

-- Input
function Console.input(label: string, default: string?): string
    return stdio.prompt("text", label, default)
end

function Console.confirm(label: string): boolean
    return stdio.prompt("confirm", label)
end

function Console.select(label: string, options: {string}): number
    return stdio.prompt("select", label, options)
end

function Console.multiselect(label: string, options: {string}): {number}
    return stdio.prompt("multiselect", label, options)
end

Console.newline = function(count: number?)
    local c = count or 1
    stdio.write(string.rep("\n", c))
end

-- StreamWriter
function Console.createStreamWriter(config: StreamWriter.StreamConfig?): StreamWriter
    local cfg = config -- Capture for type narrowing if needed, though direct access works usually if we check for nil
    local finalConfig: StreamWriter.StreamConfig = {
        boxedCode = if cfg and cfg.boxedCode ~= nil then cfg.boxedCode else defaultConfig.boxedCode,
        syntaxHighlighting = if cfg and cfg.syntaxHighlighting ~= nil then cfg.syntaxHighlighting else defaultConfig.syntaxHighlighting,
        boxWidth = if cfg and cfg.boxWidth ~= nil then cfg.boxWidth else defaultConfig.boxWidth,
    }
    
    return StreamWriter.new(finalConfig)
end

return Console
