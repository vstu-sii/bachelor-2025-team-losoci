<script setup>
import { useUserStore } from "@/stores/userStore"
import { onBeforeRouteLeave } from "vue-router"

const userStore = useUserStore()

onBeforeRouteLeave(() => {
    userStore.clearEmail()
})
</script>

<template>
    <div class="email_confirmation_message">
        <h2 class="email_confirmation_message__text">
            Письмо с подтверждением отправлено на почту:
            <span class="email_confirmation_message__text_email">{{
                userStore.email
            }}</span>
        </h2>
    </div>
</template>

<style lang="scss" scoped>
.email_confirmation_message {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 20px;
    padding: 1.75em;
    width: 100%;

    &__text {
        font-size: 24px;
        font-weight: 600;
        font-family: var(--Inter);
        line-height: 1.4;
        color: var(--text-color);
        text-align: center;
    }

    &__text_email {
        color: #b32ee7;
    }
}
</style>
