// utils/markdown.js
import { marked } from "marked"
import DOMPurify from "dompurify"

// Настройка marked
marked.setOptions({
    gfm: true,
    breaks: true,
    headerIds: false,
    mangle: false,
})

// Функция: MD → безопасный HTML
export function parseMarkdown(md) {
    if (!md) return ""
    const html = marked.parse(md)
    return DOMPurify.sanitize(html)
}
    