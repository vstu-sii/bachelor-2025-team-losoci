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

    &__text_email {
        color: var(--blue);
    }
}
</style>
