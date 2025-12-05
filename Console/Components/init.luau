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
    for _, l in ipairs(lines) do maxLineLen = math.max(maxLineLen, #l) end
    
    local boxWidth = math.min(termWidth, math.max(60, maxLineLen + 6))
    
    local headerLen = #lang + 4
    local dashLen = math.max(0, boxWidth - headerLen - 2)
    print(COLORS.brightBlack .. "┌─ " .. COLORS.cyan .. lang .. " " .. COLORS.brightBlack .. string.rep("─", dashLen) .. "┐" .. COLORS.reset)
    
    for _, line in ipairs(lines) do
         local highlighted = Highlighter.highlight(line, lang)
         local visibleLen = utf8.len(line) or #line
         local padding = math.max(0, boxWidth - visibleLen - 4)
         print(COLORS.brightBlack .. "│ " .. COLORS.reset .. highlighted .. string.rep(" ", padding) .. COLORS.brightBlack .. " │" .. COLORS.reset)
    end
    
    print(COLORS.brightBlack .. "└" .. string.rep("─", boxWidth - 2) .. "┘" .. COLORS.reset)
end

function Components.markdown(text: string)
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
    
    print(result)
end

return Components
