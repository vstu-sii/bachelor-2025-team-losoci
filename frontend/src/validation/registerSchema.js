import * as yup from "yup"

export const registerSchema = yup
    .object({
        password: yup
            .string()
            .required("Все поля должны быть заполнены")
            .min(8, "Пароль должен содержать не менее 8 символов"),

        passwordRepeat: yup
            .string()
            .required("Все поля должны быть заполнены")
            .oneOf([yup.ref("password")], "Пароли должны совпадать"),

        email: yup
            .string()
            .email("Некорректный email")
            .nullable()
            .trim()
            .test(
                "no-spaces-email",
                "Email не должен содержать пробелы",
                (value) => !value || !/\s/.test(value)
            ),

        username: yup
            .string()
            .min(6, "Логин должен содержать минимум 6 символов")
            .nullable()
            .trim()
            .test(
                "no-spaces-username",
                "Логин не должен содержать пробелы",
                (value) => !value || !/\s/.test(value)
            ),
    })
    .test(
        "email-or-username",
        "Введите email или имя пользователя",
        (value) => !!(value.email || value.username)
    )
