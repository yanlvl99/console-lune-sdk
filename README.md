# 🎨 Console Module

A powerful terminal output module for Luau/Lune with colors, styles, and formatting.

## Installation

### Step 1: Copy the Package

Copy the `GenAi` folder to your project's packages directory:

```
YourProject/
├── Console/
│   └── init.luau
├── .luaurc
└── your_script.luau
```

### Step 2: Add Alias

Add the alias to your `.luaurc`:

```json
{
  "aliases": {
    "Console": "./Console"
  }
}
```

## Usage

```lua
local Console = require("@Console")

-- Basic colored text
Console.success("Operation completed!")
Console.error("Something went wrong!")
Console.warn("Be careful!")
Console.info("Here's some info")
Console.debug("Debug message")

-- Colored strings
print(Console.red("Red text"))
print(Console.green("Green text"))
print(Console.blue("Blue text"))
```

## API Reference

### Basic Colors

| Function | Description |
|----------|-------------|
| `red(text)` | Red text |
| `green(text)` | Green text |
| `yellow(text)` | Yellow text |
| `blue(text)` | Blue text |
| `magenta(text)` | Magenta text |
| `cyan(text)` | Cyan text |
| `white(text)` | White text |
| `gray(text)` | Gray text |

### Text Styles

| Function | Description |
|----------|-------------|
| `bold(text)` | Bold text |
| `italic(text)` | Italic text |
| `underline(text)` | Underlined text |
| `dim(text)` | Dimmed text |
| `strikethrough(text)` | Strikethrough text |

### Formatted Printing

| Function | Description |
|----------|-------------|
| `success(msg)` | ✅ Green success message |
| `error(msg)` | ❌ Red error message |
| `warn(msg)` | ⚠️ Yellow warning message |
| `info(msg)` | ℹ️ Cyan info message |
| `debug(msg)` | 🔍 Gray debug message |
| `log(msg)` | White log message |

### Layout

| Function | Parameters | Description |
|----------|------------|-------------|
| `header(title, char?)` | Title, optional char | Styled header with dividers |
| `divider(char?, length?)` | Char, length | Horizontal divider |
| `newline(count?)` | Optional count | Print empty lines |
| `box(text, padding?)` | Text, padding | Text in a box |

### Data Display

| Function | Parameters | Description |
|----------|------------|-------------|
| `table(data, title?)` | Object, title | Pretty print a table |
| `list(items, bullet?)` | Array, bullet | Bulleted list |
| `numbered(items)` | Array | Numbered list |

### Progress & Animation

| Function | Parameters | Description |
|----------|------------|-------------|
| `progress(current, total, width?)` | Numbers | Progress bar |
| `spinner(frames?, interval?)` | Arrays, number | Animated spinner |

### Advanced Formatting

| Function | Parameters | Description |
|----------|------------|-------------|
| `format(text, color?, style?, bg?)` | All optional | Custom format |
| `gradient(text, startColor, endColor)` | Colors | Gradient text |
| `rainbow(text)` | Text | Rainbow colored text |
| `rgb(text, r, g, b)` | RGB values | Custom RGB color |
| `bgRgb(text, r, g, b)` | RGB values | Custom RGB background |

### Code & Markdown

| Function | Parameters | Description |
|----------|------------|-------------|
| `code(text, lang?)` | Code, language | Syntax highlighted code block |
| `highlightSyntax(line, lang)` | Line, language | Highlight Lua/Luau syntax |
| `markdown(text)` | Markdown text | Render markdown with colors |

### Streaming

| Function | Description |
|----------|-------------|
| `write(text)` | Write without newline (stdio) |
| `writeln(text)` | Write with newline (stdio) |

### Terminal Control

| Function | Description |
|----------|-------------|
| `clear()` | Clear terminal |
| `clearLine()` | Clear current line |
| `moveCursor(row, col)` | Move cursor position |
| `saveCursor()` | Save cursor position |
| `restoreCursor()` | Restore cursor position |
| `hideCursor()` | Hide cursor |
| `showCursor()` | Show cursor |

## Examples

### Colored Output

```lua
local Console = require("@Console")

Console.header("My Application")
Console.success("Server started on port 3000")
Console.info("Waiting for connections...")
```

### Progress Bar

```lua
for i = 1, 100 do
    Console.progress(i, 100)
    task.wait(0.05)
end
```

### Code Highlighting

```lua
Console.code([[
local function hello(name)
    print("Hello, " .. name)
end
]], "lua")
```

### Gradient & Rainbow

```lua
print(Console.gradient("Beautiful gradient text!", "red", "blue"))
print(Console.rainbow("Rainbow colors!"))
```

### Custom RGB

```lua
print(Console.rgb("Custom color!", 255, 100, 50))
print(Console.bgRgb("With background!", 50, 50, 100))
```

### Tables & Lists

```lua
Console.table({
    name = "John",
    age = 25,
    city = "New York",
}, "User Info")

Console.list({ "First item", "Second item", "Third item" })
Console.numbered({ "Step one", "Step two", "Step three" })
```

### Box Text

```lua
Console.box("Welcome to my app!\nEnjoy your stay.")
```

## Available Colors

**Standard:** black, red, green, yellow, blue, magenta, cyan, white

**Bright:** brightBlack, brightRed, brightGreen, brightYellow, brightBlue, brightMagenta, brightCyan, brightWhite

**Gradient Colors:** red, green, blue, yellow, magenta, cyan, white, orange, pink, purple

## Credits

- Made by yanlvl99_ [Discord](https://discord.com/channels/@me/1222190313204879421)

## License

MIT
