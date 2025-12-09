// src/utils/promptUtils.ts
export function buildPromptFromForm(recipient, formData) {
    const parts = []

    // Получатель
    if (recipient.username) parts.push(`Получатель: @${recipient.username}`)
    else if (recipient.name) parts.push(`Получатель: ${recipient.name}`)

    // Дата рождения
    if (recipient.birthdate) {
        const date = new Date(recipient.birthdate).toLocaleDateString("ru-RU")
        parts.push(`Дата рождения: ${date}`)
    }

    // Пол
    if (recipient.gender) {
        const gender = recipient.gender === "male" ? "мужской" : "женский"
        parts.push(`Пол: ${gender}`)
    }

    // Описание от получателя
    if (recipient.description) {
        parts.push(`О себе: ${recipient.description.trim()}`)
    }

    // Событие
    if (formData.event) {
        parts.push(`Событие: ${formData.event.trim()}`)
    }

    // Дополнительное описание
    if (formData.description) {
        parts.push(`Дополнительно: ${formData.description.trim()}`)
    }

    // Если ничего нет — возвращаем пустую строку
    return parts.length > 0 ? parts.join("\n") : ""
}
