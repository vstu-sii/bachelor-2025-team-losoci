<script setup>
import { ref, computed } from "vue"

import UserService from "@/services/UserService"

import { useRouter } from "vue-router"
import { validate } from "@/middlewares/validate"
import { loginSchema } from "@/validation/loginSchema"

import InputWithTitle from "@/components/InputWithTitle.vue"

import EyeOpen from "@/assets/svg/EyeOpen.svg"
import EyeClose from "@/assets/svg/EyeClose.svg"
import IWarning from "@/assets/icons/IWarning.vue"

const errors = {
    400: "Неправильный Логин/Почта или пароль",
    404: "Пользователь не найден",
    422: "Все поля обязательны для заполнения",
    500: "Внутренняя ошибка сервера",
}

const userLoginData = ref({
    input: "",
    password: "",
})

const errorExist = ref({
    error: false,
    errorMessage: "",
})

const router = useRouter()

const showPassword = ref(false)

const passwordType = computed(() => (showPassword.value ? "text" : "password"))
const passwordIcon = computed(() => (showPassword.value ? EyeClose : EyeOpen))

const isEmail = computed(() =>
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userLoginData.value.input)
)
const isUsername = computed(() => userLoginData.value.input && !isEmail.value)

const toggleShowPassword = () => {
    showPassword.value = !showPassword.value
}

async function login() {
    errorExist.value = { error: false, errorMessage: "" }

    const userPayload = {
        password: userLoginData.value.password,
        ...(isEmail.value
            ? { email: userLoginData.value.input }
            : isUsername.value
            ? { username: userLoginData.value.input }
            : {}),
    }

    try {
        const { valid, errors: validationErrors } = await validate(
            loginSchema,
            userPayload
        )

        if (!valid) {
            errorExist.value = {
                error: true,
                errorMessage: Object.values(validationErrors)[0],
            }
            return
        }

        await UserService.login(userPayload)

        router.push("/")
    } catch (err) {
        if (err.response && errors[err.response.status]) {
            errorExist.value = {
                error: true,
                errorMessage: errors[err.response.status],
            }
        } else {
            errorExist.value = {
                error: true,
                errorMessage: "Внутренняя ошибка сервера",
            }
        }
    }
}
</script>

<template>
    <div class="authorization_form__wrapper">
        <form class="authorization_form">
            <div class="authorization_form__text">
                <h2 class="authorization_form__title">Добро пожаловать</h2>
                <h3 class="authorization_form__subtitle">
                    Войдите в свой аккуант чтобы продолжить
                </h3>
            </div>
            <div class="authorization_form__error" v-if="errorExist.error">
                <IWarning class="authorization_form__error__icon" />
                <span>{{ errorExist.errorMessage }}</span>
            </div>
            <div class="authorization_form__main">
                <div class="authorization_form__inputs">
                    <InputWithTitle
                        title="Почта/Логин"
                        placeholder="Почта/Логин"
                        v-model="userLoginData.input"
                        id="login_input"
                    />
                    <InputWithTitle
                        title="Пароль"
                        placeholder="Пароль"
                        v-model="userLoginData.password"
                        :type="passwordType"
                        :image="passwordIcon"
                        @image-click="toggleShowPassword"
                        id="password_input"
                    />
                </div>

                <div class="authorization_form__buttons">
                    <BaseButton text="Войти" @click="login" />
                    <button
                        type="button"
                        class="authorization_form__registration_btn"
                        @click="router.push('/registration')"
                    >
                        Нет аккаунта?
                        <span>Зарегистрироваться</span>
                    </button>
                </div>
            </div>
        </form>
        <span></span>
        <button
            type="button"
            class="authorization_form__registration_btn"
            @click="router.push('/email-recover')"
        >
            Забыли пароль? Вы всегда можете его <span>восстановить</span>
        </button>
    </div>
</template>

<style lang="scss" scoped>
.authorization_form {
    width: 100%;
    max-width: 575px;
    display: flex;
    flex-direction: column;
    gap: 44px;

    &__wrapper {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        height: 100%;
    }

    &__title {
        font-size: 4.5rem;
        font-weight: 700;
        font-family: var(--Montserrat);
        line-height: 1.2;
        text-align: center;
        color: var(--white);
    }

    &__subtitle {
        font-size: 1.5rem;
        font-weight: 400;
        color: var(--text-color);
        font-family: var(--Inter);
        line-height: 1.2;
        text-align: center;
    }

    &__main {
        display: flex;
        flex-direction: column;
        gap: 44px;
    }

    &__inputs {
        display: flex;
        flex-direction: column;
        gap: 44px;

        @include desktop {
            gap: 32px;
        }

        @include tablet {
            gap: 28px;
        }

        @include mobile {
            gap: 24px;
        }
    }

    &__error {
        padding: 1em;
        font-family: var(--Inter);
        font-size: 1rem;
        color: var(--red);
        display: flex;
        align-items: center;
        gap: 12px;
        background-color: var(--pink);
        border-radius: 16px;

        &__icon {
            width: 44px;
            height: 44px;
        }
    }

    &__buttons {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 24px;
    }

    &__registration_btn {
        font-family: --Inter;
        font-size: 1.25rem;
        color: var(--text-color);

        &:focus-visible {
            outline: 2px solid var(--grey);
            outline-offset: 2px;
        }

        & span {
            position: relative;
            text-decoration: none;

            &::after {
                content: "";
                position: absolute;
                left: 50%;
                bottom: -2px;
                width: 50%;
                height: 2px;
                background: currentColor;
                transition: width 0.3s ease;
            }

            &::before {
                content: "";
                position: absolute;
                right: 50%;
                bottom: -2px;
                width: 50%;
                height: 2px;
                background: currentColor;
                transition: width 0.3s ease;
            }
        }

        &:hover span::after,
        &:hover span::before {
            width: 0%;
        }
    }
}
</style>
