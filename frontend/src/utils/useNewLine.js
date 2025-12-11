export function formatMessage(input) {
    if (!input) return ""

    if (input.startsWith('"') && input.endsWith('"')) {
        input = input.slice(1, -1)
    }

    input = input.replace(/\[READY_TO_SEARCH\]/g, "")

    return input
        .replace(/\\n/g, "\n")
        .replace(/\r\n/g, "\n")
        .replace(/\n/g, "<br>")
}
