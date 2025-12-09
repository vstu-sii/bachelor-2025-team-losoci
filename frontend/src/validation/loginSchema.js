import * as yup from "yup"

export const loginSchema = yup
    .object({
        password: yup
            .string()
            .required("Все поля должны быть заполнены")
            .min(8, "Пароль должен содержать не менее 8 символов"),
        email: yup
            .string()
            .email("Некорректный email")
            .notRequired()
            .nullable()
            .trim(),
        username: yup
            .string()
            .min(6, "Почта/Логин должны содеражть минимум 6 символов")
            .notRequired()
            .nullable()
            .trim(),
    })
    .test(
        "email-or-username",
        "Введите email или имя пользователя",
        (value) => !!(value.email || value.username)
    )
