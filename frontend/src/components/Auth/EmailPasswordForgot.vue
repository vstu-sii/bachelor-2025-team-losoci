<script setup>
import { ref } from "vue"

import UserService from "@/services/UserService"
import { useUserStore } from "@/stores/userStore"
import { useRouter } from "vue-router"

const userStore = useUserStore()
const router = useRouter()

const email = ref("")

const errorExist = ref({
    error: false,
    errorMessage: "",
})

function isValidEmail(value) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
}

async function resetPassword() {
    errorExist.value = { error: false, errorMessage: "" }

    if (!email.value) {
        errorExist.value = {
            error: true,
            errorMessage: "Email обязателен для заполнения",
        }
        return
    }

    if (!isValidEmail(email.value)) {
        errorExist.value = {
            error: true,
            errorMessage: "Некорректный формат email",
        }
        return
    }

    try {
        await UserService.resetPassword({ email: email.value })

        userStore.setEmail(email.value)

        router.push("/email-recover-success")
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
    <div class="email_password_recover">
        <h2 class="email_password_recover__text">
            Укажите почту для восстановления
        </h2>
        <BaseInput placeholder="Почта" v-model="email" />
        <span class="email_password_recover__error" v-if="errorExist.error">
            {{ errorExist.errorMessage }}
        </span>
        <BaseButton text="Восстановить" @click="resetPassword"></BaseButton>
    </div>
</template>

<style lang="scss" scoped>
.email_password_recover {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 20px;
    padding: 1.75em;
    width: 100%;

    &__text {
        font-size: 2rem;
        font-weight: 600;
        font-family: var(--Inter);
        line-height: 1.4;
        color: var(--text-color);
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
