<script setup>
import { ref, computed } from "vue"

import UserService from "@/services/UserService"

import { useUserStore } from "@/stores/userStore"
import { useRouter } from "vue-router"

import { validate } from "@/middlewares/validate"
import { registerSchema } from "@/validation/registerSchema"

import InputWithTitle from "@/components/InputWithTitle.vue"

import EyeOpen from "@/assets/svg/EyeOpen.svg"
import EyeClose from "@/assets/svg/EyeClose.svg"
import IWarning from "@/assets/icons/IWarning.vue"

const errors = {
    400: "Пользовытель уже существует",
    422: "Все поля обязательны для заполнения",
    500: "Внутренняя ошибка сервера",
}

const userRegisterData = ref({
    email: "",
    username: "",
    password: "",
    passwordRepeat: "",
})

const errorExist = ref({
    error: false,
    errorMessage: "",
})

const router = useRouter()
const userStore = useUserStore()

const showPassword = ref(false)
const showPasswordRepeat = ref(false)

const passwordType = computed(() => (showPassword.value ? "text" : "password"))
const passwordRepeatType = computed(() =>
    showPasswordRepeat.value ? "text" : "password"
)

const passwordIcon = computed(() => (showPassword.value ? EyeClose : EyeOpen))
const passwordRepeatIcon = computed(() =>
    showPasswordRepeat.value ? EyeClose : EyeOpen
)

const toggleShowPassword = () => {
    showPassword.value = !showPassword.value
}

const toggleShowPasswordRepeat = () => {
    showPasswordRepeat.value = !showPasswordRepeat.value
}

async function register() {
    errorExist.value = { error: false, errorMessage: "" }

    const userPayload = {
        password: userRegisterData.value.password,
        email: userRegisterData.value.email,
        username: userRegisterData.value.username,
    }

    try {
        const { valid, errors: validationErrors } = await validate(
            registerSchema,
            {
                ...userPayload,
                passwordRepeat: userRegisterData.value.passwordRepeat,
            }
        )

        if (!valid) {
            errorExist.value = {
                error: true,
                errorMessage: Object.values(validationErrors)[0],
            }
            return
        }

        await UserService.createUser(userPayload)
        userStore.setEmail(userPayload.email)

        router.push("/email-confirmation")
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
    <form class="registration_form">
        <div class="registration_form__text">
            <h2 class="registration_form__title">Добро пожаловать</h2>
            <h3 class="registration_form__subtitle">
                Зарегистрируйте свой аккаунт чтобы продолжить
            </h3>
        </div>
        <div class="registration_form__error" v-if="errorExist.error">
            <IWarning class="registration_form__error__icon" />
            <span>{{ errorExist.errorMessage }}</span>
        </div>
        <div class="registration_form__wrapper">
            <div class="registration_form__inputs">
                <InputWithTitle
                    placeholder="Почта"
                    title="Почта"
                    v-model="userRegisterData.email"
                    id="email"
                />
                <InputWithTitle
                    placeholder="Логин"
                    title="Логин"
                    v-model="userRegisterData.username"
                    id="login"
                />
                <InputWithTitle
                    :type="passwordType"
                    title="Пароль"
                    placeholder="Пароль"
                    v-model="userRegisterData.password"
                    :image="passwordIcon"
                    @image-click="toggleShowPassword"
                    id="password"
                />
                <InputWithTitle
                    placeholder="Повторите пароль"
                    title="Повторите пароль"
                    v-model="userRegisterData.passwordRepeat"
                    :type="passwordRepeatType"
                    :image="passwordRepeatIcon"
                    @image-click="toggleShowPasswordRepeat"
                    id="password_repeat"
                />
            </div>

            <div class="registration_form__buttons">
                <BaseButton
                    text="Зарегистрироваться"
                    @click="register"
                /><button
                    type="button"
                    class="registration_form__registration_btn"
                    @click="router.push('/authorization')"
                >
                    Уже есть аккаунт?
                    <span>Войти</span>
                </button>
            </div>
        </div>
    </form>
</template>

<style lang="scss" scoped>
.registration_form {
    width: 100%;
    max-width: 575px;
    display: flex;
    flex-direction: column;
    gap: 16px;

    &__text {
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    &__title {
        font-size: 3rem;
        font-weight: 700;
        font-family: var(--Montserrat);
        line-height: 1.2;
        text-align: center;
        max-width: 400px;
        color: var(--white);
    }

    &__subtitle {
        font-size: 1.5rem;
        font-weight: 400;
        color: var(--text-color);
        font-family: var(--Inter);
        line-height: 1.2;
        max-width: 320px;
        text-align: center;
    }

    &__wrapper {
        display: flex;
        flex-direction: column;
        gap: 44px;
    }

    &__inputs {
        display: flex;
        flex-direction: column;
        gap: 24px;
    }

    &__error {
        padding: 0.6em;
        font-family: var(--Inter);
        font-size: 1rem;
        color: var(--red);
        display: flex;
        align-items: center;
        gap: 12px;
        background-color: var(--pink);
        border-radius: 16px;

        @include desktop {
            padding: 0.4em;
        }

        &__icon {
            width: 44px;
            height: 44px;

            @include desktop {
                width: 32px;
                height: 32px;
            }
        }
    }

    &__buttons {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
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
                left: 0;
                bottom: -2px;
                width: 100%;
                height: 2px;
                background: currentColor;
                transition: width 0.3s ease;
            }
        }

        &:hover span::after {
            width: 0%;
        }
    }
}
</style>
