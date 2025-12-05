# Exemplo de Como Converter Tabelas Markdown para apiTable

## Tabela Markdown Tradicional (ANTES)

```markdown
| Method | Description | Color |
|--------|-------------|-------|
| `Console.success(message: string)` | Success message with `[OK]` prefix | Green |
| `Console.error(message: string)` | Error message with `[X]` prefix | Red |
| `Console.warn(message: string)` | Warning message with `[!]` prefix | Yellow |
```

## Usando Console.apiTable (DEPOIS)

```lua
Console.apiTable(
    {"Method", "Description", "Color"},
    {
        {"`Console.success(message: string)`", "Success message with `[OK]` prefix", "Green"},
        {"`Console.error(message: string)`", "Error message with `[X]` prefix", "Red"},
        {"`Console.warn(message: string)`", "Warning message with `[!]` prefix", "Yellow"},
    },
    "Logging Functions"  -- Título opcional
)
```

## Resultado Visual

```
Logging Functions
┌──────────────────────────────────┬─────────────────────────────────────────┬───────┐
│ Method                           │ Description                             │ Color │
├──────────────────────────────────┼─────────────────────────────────────────┼───────┤
│ `Console.success(message: string)` │ Success message with `[OK]` prefix     │ Green │
│ `Console.error(message: string)`   │ Error message with `[X]` prefix        │ Red   │
│ `Console.warn(message: string)`    │ Warning message with `[!]` prefix      │ Yellow│
└──────────────────────────────────┴─────────────────────────────────────────┴───────┘
```

## Vantagens

✅ **Bordas em formato box ASCII** - Visual mais profissional
✅ **Tamanho automático** - Colunas se ajustam ao conteúdo
✅ **Headers destacados** - Cabeçalhos em amarelo/negrito
✅ **Cores customizadas** - Bordas em cyan
✅ **Título opcional** - Pode adicionar um título à tabela

## API

```lua
Console.apiTable(
    headers: {string},  -- Array com nomes das colunas
    rows: {{string}},   -- Array de arrays com os dados
    title: string?      -- Título opcional
)
```
