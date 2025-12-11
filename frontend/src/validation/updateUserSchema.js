import * as yup from "yup"

export const userUpdateSchema = yup.object({
    email: yup
        .string()
        .email("Некорректный формат email")
        .nullable()
        .trim()
        .test(
            "no-spaces-email",
            "Email не должен содержать пробелы",
            (value) => !value || !/\s/.test(value)
        ),

    username: yup
        .string()
        .min(6, "Имя пользователя должно содержать минимум 6 символов")
        .nullable()
        .trim()
        .test(
            "no-spaces-username",
            "Имя пользователя не должно содержать пробелы",
            (value) => !value || !/\s/.test(value)
        ),

    name: yup
        .string()
        .nullable()
        .trim()
        .test(
            "valid-name",
            "Имя должно начинаться с заглавной буквы и содержать только буквы",
            (value) => !value || /^[A-ZА-Я][a-zа-я]+$/.test(value)
        ),

    surname: yup
        .string()
        .nullable()
        .trim()
        .test(
            "valid-surname",
            "Фамилия должна начинаться с заглавной буквы и содержать только буквы",
            (value) => !value || /^[A-ZА-Я][a-zа-я]+$/.test(value)
        ),

    birthdate: yup
        .string()
        .nullable()
        .trim()
        .test(
            "valid-birthdate",
            "Дата рождения должна быть корректной (ГГГГ-ММ-ДД)",
            (value) => !value || !isNaN(Date.parse(value))
        ),

    gender: yup
        .string()
        .nullable()
        .oneOf(
            ["мужской", "женский"],
            "Пол должен быть 'мужской' или 'женский'"
        ),

    description: yup.string().nullable().trim(),

    telegram_link: yup
        .string()
        .nullable()
        .trim()
        .test(
            "valid-telegram",
            "Ссылка на Telegram должна начинаться с @",
            (value) => !value || value.startsWith("@")
        ),
})
