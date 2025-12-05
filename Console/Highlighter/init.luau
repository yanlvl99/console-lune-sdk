local Utils = require("@Utils")
local COLORS = Utils.COLORS

local Highlighter = {}

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
    },
    html = {
        keywords = {
            -- Common HTML tags (without brackets, as the highlighter finds identifiers)
            ["html"]=1, ["head"]=1, ["body"]=1, ["div"]=1, ["span"]=1, ["p"]=1, ["a"]=1, 
            ["img"]=1, ["h1"]=1, ["h2"]=1, ["h3"]=1, ["h4"]=1, ["h5"]=1, ["h6"]=1,
            ["ul"]=1, ["ol"]=1, ["li"]=1, ["table"]=1, ["tr"]=1, ["td"]=1, ["th"]=1,
            ["form"]=1, ["input"]=1, ["button"]=1, ["select"]=1, ["option"]=1, ["textarea"]=1,
            ["script"]=1, ["style"]=1, ["link"]=1, ["meta"]=1, ["br"]=1, ["hr"]=1,
            ["strong"]=1, ["em"]=1, ["doctype"]=1,
            -- Common attributes
            ["class"]=1, ["id"]=1, ["src"]=1, ["href"]=1, ["alt"]=1,
            ["title"]=1, ["data"]=1, ["lang"]=1, ["rel"]=1, ["type"]=1, ["name"]=1,
            ["value"]=1, ["placeholder"]=1, ["action"]=1, ["method"]=1
        },
        comment = "<!--", -- Highlights from <!-- to end of line
    },
    css = {
        keywords = {
            -- Properties
            ["color"]=1, ["background"]=1, ["background-color"]=1, ["border"]=1, 
            ["margin"]=1, ["padding"]=1, ["font-size"]=1, ["font-family"]=1,
            ["width"]=1, ["height"]=1, ["display"]=1, ["position"]=1,
            ["top"]=1, ["right"]=1, ["bottom"]=1, ["left"]=1, ["float"]=1,
            ["clear"]=1, ["text-align"]=1, ["line-height"]=1, ["flex"]=1,
            ["grid"]=1, ["z-index"]=1, ["opacity"]=1, ["transform"]=1,
            ["transition"]=1, ["box-shadow"]=1, ["text-decoration"]=1,
            -- Common values and units
            ["auto"]=1, ["none"]=1, ["block"]=1, ["inline"]=1, ["inline-block"]=1,
            ["absolute"]=1, ["relative"]=1, ["fixed"]=1, ["static"]=1, ["inherit"]=1,
            ["initial"]=1, ["unset"]=1, ["red"]=1, ["blue"]=1, ["green"]=1, ["black"]=1,
            ["white"]=1, ["transparent"]=1, ["px"]=1, ["em"]=1, ["rem"]=1, ["vw"]=1, 
            ["vh"]=1, ["%"]=1
        },
        comment = "/%*", -- Highlights from /* to end of line
    },
    kotlin = {
        keywords = {
            ["fun"]=1, ["val"]=1, ["var"]=1, ["class"]=1, ["object"]=1, ["interface"]=1,
            ["if"]=1, ["else"]=1, ["when"]=1, ["for"]=1, ["while"]=1, ["do"]=1,
            ["return"]=1, ["break"]=1, ["continue"]=1, ["try"]=1, ["catch"]=1, ["finally"]=1,
            ["throw"]=1, ["package"]=1, ["import"]=1, ["public"]=1, ["private"]=1,
            ["protected"]=1, ["internal"]=1, ["open"]=1, ["abstract"]=1, ["sealed"]=1,
            ["data"]=1, ["companion"]=1, ["override"]=1, ["suspend"]=1, ["inline"]=1,
            ["lateinit"]=1, ["const"]=1, ["init"]=1, ["this"]=1, ["super"]=1,
            ["true"]=1, ["false"]=1, ["null"]=1, ["is"]=1, ["in"]=1, ["as"]=1
        },
        comment = "//",
    },
    csharp = {
        keywords = {
            ["class"]=1, ["struct"]=1, ["interface"]=1, ["enum"]=1, ["namespace"]=1,
            ["using"]=1, ["public"]=1, ["private"]=1, ["protected"]=1, ["internal"]=1,
            ["static"]=1, ["readonly"]=1, ["const"]=1, ["void"]=1, ["int"]=1, ["string"]=1,
            ["bool"]=1, ["double"]=1, ["float"]=1, ["decimal"]=1, ["var"]=1, ["dynamic"]=1,
            ["if"]=1, ["else"]=1, ["switch"]=1, ["case"]=1, ["default"]=1, ["for"]=1,
            ["foreach"]=1, ["while"]=1, ["do"]=1, ["return"]=1, ["break"]=1, ["continue"]=1,
            ["try"]=1, ["catch"]=1, ["finally"]=1, ["throw"]=1, ["new"]=1, ["this"]=1,
            ["base"]=1, ["async"]=1, ["await"]=1, ["virtual"]=1, ["override"]=1,
            ["abstract"]=1, ["sealed"]=1, ["partial"]=1, ["get"]=1, ["set"]=1,
            ["true"]=1, ["false"]=1, ["null"]=1, ["is"]=1, ["as"]=1, ["in"]=1, ["out"]=1
        },
        comment = "//",
    },
    swift = {
        keywords = {
            ["func"]=1, ["let"]=1, ["var"]=1, ["class"]=1, ["struct"]=1, ["enum"]=1,
            ["protocol"]=1, ["extension"]=1, ["import"]=1, ["if"]=1, ["else"]=1, ["guard"]=1,
            ["switch"]=1, ["case"]=1, ["default"]=1, ["for"]=1, ["while"]=1, ["repeat"]=1,
            ["return"]=1, ["break"]=1, ["continue"]=1, ["fallthrough"]=1, ["do"]=1,
            ["try"]=1, ["catch"]=1, ["throw"]=1, ["throws"]=1, ["defer"]=1, ["in"]=1,
            ["public"]=1, ["private"]=1, ["fileprivate"]=1, ["internal"]=1, ["open"]=1,
            ["static"]=1, ["final"]=1, ["override"]=1, ["mutating"]=1, ["lazy"]=1,
            ["weak"]=1, ["unowned"]=1, ["required"]=1, ["convenience"]=1, ["init"]=1,
            ["deinit"]=1, ["self"]=1, ["super"]=1, ["nil"]=1, ["true"]=1, ["false"]=1,
            ["is"]=1, ["as"]=1, ["await"]=1, ["async"]=1, ["inout"]=1
        },
        comment = "//",
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
LANGUAGES.cpp = LANGUAGES.c 
LANGUAGES["c++"] = LANGUAGES.c
LANGUAGES.rs = LANGUAGES.rust
LANGUAGES.golang = LANGUAGES.go
LANGUAGES.json = LANGUAGES.javascript
LANGUAGES.kt = LANGUAGES.kotlin
LANGUAGES.cs = LANGUAGES.csharp
LANGUAGES["c#"] = LANGUAGES.csharp

function Highlighter.highlight(line: string, language: string): string
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

             if nearestType == "comment" then result = result .. COLORS.gray .. text .. COLORS.reset; remaining = "" 
             elseif nearestType == "string" then result = result .. COLORS.pink .. text .. COLORS.reset; remaining = remaining:sub((matchEnd :: number) + 1)
             elseif nearestType == "number" then result = result .. COLORS.orange .. text .. COLORS.reset; remaining = remaining:sub((matchEnd :: number) + 1)
             elseif nearestType == "identifier" then
                 if keywords[text] then result = result .. COLORS.purple .. text .. COLORS.reset
                 elseif remaining:sub((matchEnd :: number) + 1, (matchEnd :: number) + 1) == "(" then result = result .. COLORS.teal .. text .. COLORS.reset
                 else result = result .. COLORS.white .. text .. COLORS.reset end
                 remaining = remaining:sub((matchEnd :: number) + 1)
             else result = result .. text; remaining = remaining:sub((matchEnd :: number) + 1) end
        end
    end
    return result
end

return Highlighter
