<script setup>
import { ref, computed } from "vue"
import { useRoute, useRouter } from "vue-router"

import { UserService } from "@/services"

import EyeOpen from "@/assets/svg/EyeOpen.svg"
import EyeClose from "@/assets/svg/EyeClose.svg"

const route = useRoute()
const router = useRouter()

const errors = {
    400: "Неправильный формат пароля",
    422: "Все поля обязательны для заполнения",
    500: "Внутренняя ошибка сервера",
}

const token = route.query.token

const password = ref("")
const passwordRepeat = ref("")

const errorExist = ref({
    error: false,
    errorMessage: "",
})

const showPassword = ref(false)
const showPasswordRepeat = ref(false)

const passwordType = computed(() => (showPassword.value ? "text" : "password"))
const passwordIcon = computed(() => (showPassword.value ? EyeClose : EyeOpen))

const passwordRepeatType = computed(() =>
    showPasswordRepeat.value ? "text" : "password"
)
const passwordRepeatIcon = computed(() =>
    showPasswordRepeat.value ? EyeClose : EyeOpen
)

const toggleShowPasswordRepeat = () => {
    showPasswordRepeat.value = !showPasswordRepeat.value
}

const toggleShowPassword = () => {
    showPassword.value = !showPassword.value
}

async function updatePassword() {
    errorExist.value = { error: false, errorMessage: "" }

    if (!password.value || !passwordRepeat.value) {
        errorExist.value = {
            error: true,
            errorMessage: "Все поля должны быть заполнены",
        }
        return
    }

    if (password.value.length < 8) {
        errorExist.value = {
            error: true,
            errorMessage: "Пароль должен содержать не менее 8 символов",
        }
        return
    }

    if (password.value !== passwordRepeat.value) {
        errorExist.value = {
            error: true,
            errorMessage: "Пароли должны совпадать",
        }
        return
    }

    try {
        await UserService.updatePassword(token, {
            password: password.value,
        })
        router.push("/authorization")
    } catch (err) {
        errorExist.value = {
            error: true,
            errorMessage:
                errors[err.response?.status] || "Внутренняя ошибка сервера",
        }
    }
}
</script>

<template>
    <div class="email_password_reset">
        <h2 class="email_password_reset__text">Придумайте новый пароль</h2>
        <div class="email_password_reset__inputs">
            <BaseInput
                :type="passwordType"
                placeholder="Новый пароль"
                :image="passwordIcon"
                v-model="password"
                @image-click="toggleShowPassword"
            />
            <BaseInput
                :type="passwordRepeatType"
                placeholder="Повторите пароль"
                :image="passwordRepeatIcon"
                v-model="passwordRepeat"
                @image-click="toggleShowPasswordRepeat"
            />
        </div>
        <span class="email_password_reset__error" v-if="errorExist.error">
            {{ errorExist.errorMessage }}
        </span>
        <BaseButton text="Сохранить" @click="updatePassword"></BaseButton>
    </div>
</template>

<style lang="scss" scoped>
.email_password_reset {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 20px;
    padding: 28px;
    width: 100%;
    box-shadow: 0px 4px 15px rgba(0, 0, 0, 0.15);
    border-radius: 24px;

    &__text {
        font-size: 20px;
        font-weight: 600;
        font-family: var(--Inter);
        line-height: 1.4;
        text-align: center;
    }

    &__inputs {
        width: 100%;
        display: flex;
        flex-direction: column;
        gap: 20px;
    }
}
</style>
