// Wraps text in the ANSI colour code `code`
`define ANSI(code, text) {"\033[", code, "m", text, "\033[0m"}
