<script setup>
import { ref, onMounted } from "vue"
import { useRoute, useRouter } from "vue-router"

import { UserService } from "@/services"

const route = useRoute()
const router = useRouter()

const token = route.query.token

const emailVerified = ref(false)

onMounted(async () => {
    if (token) {
        localStorage.setItem("accessToken", token)
        const response = await UserService.verifyEmail(token)
        emailVerified.value = response.data.isVerified
    }
})
</script>

<template>
    <div class="email_confirmation_message">
        <h2 class="email_confirmation_message__text" v-if="emailVerified">
            Аккаунт успешно подтвержден
        </h2>
        <h2 class="email_confirmation_message__text" v-else>
            Подождите, пожалуйста, сейчас мы подтверждаем ваш аккаунт
        </h2>
        <div
            class="email_confirmation_message__loading"
            v-if="!emailVerified"
        ></div>
        <BaseButton text="На главную" @click="router.push('/')"></BaseButton>
    </div>
</template>

<style lang="scss" scoped>
.email_confirmation_message {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
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

    &__loading {
        display: flex;
        align-items: center;
        justify-content: center;
        height: 44px;
        width: 100%;
        overflow: visible;
    }

    &__loading:before {
        content: "";
        display: block;
        position: fixed;
        top: 20;
        left: 0;
        width: 20px;
        height: 20px;
    }

    &__loading:not(:required) {
        font: 0/0 a;
        color: transparent;
        text-shadow: none;
        background-color: transparent;
        border: 0;
    }

    &__loading:not(:required):after {
        content: "";
        display: block;
        font-size: 10px;
        width: 1em;
        height: 1em;
        margin-top: -0.5em;
        -webkit-animation: spinner 1500ms infinite linear;
        -moz-animation: spinner 1500ms infinite linear;
        -ms-animation: spinner 1500ms infinite linear;
        -o-animation: spinner 1500ms infinite linear;
        animation: spinner 1500ms infinite linear;
        border-radius: 0.5em;
        -webkit-box-shadow: rgba(0, 0, 0, 0.75) 1.5em 0 0 0,
            rgba(0, 0, 0, 0.75) 1.1em 1.1em 0 0, rgba(0, 0, 0, 0.75) 0 1.5em 0 0,
            rgba(0, 0, 0, 0.75) -1.1em 1.1em 0 0,
            rgba(0, 0, 0, 0.5) -1.5em 0 0 0,
            rgba(0, 0, 0, 0.5) -1.1em -1.1em 0 0,
            rgba(0, 0, 0, 0.75) 0 -1.5em 0 0,
            rgba(0, 0, 0, 0.75) 1.1em -1.1em 0 0;
        box-shadow: rgba(0, 0, 0, 0.75) 1.5em 0 0 0,
            rgba(0, 0, 0, 0.75) 1.1em 1.1em 0 0, rgba(0, 0, 0, 0.75) 0 1.5em 0 0,
            rgba(0, 0, 0, 0.75) -1.1em 1.1em 0 0,
            rgba(0, 0, 0, 0.75) -1.5em 0 0 0,
            rgba(0, 0, 0, 0.75) -1.1em -1.1em 0 0,
            rgba(0, 0, 0, 0.75) 0 -1.5em 0 0,
            rgba(0, 0, 0, 0.75) 1.1em -1.1em 0 0;
    }

    @-webkit-keyframes spinner {
        0% {
            -webkit-transform: rotate(0deg);
            -moz-transform: rotate(0deg);
            -ms-transform: rotate(0deg);
            -o-transform: rotate(0deg);
            transform: rotate(0deg);
        }
        100% {
            -webkit-transform: rotate(360deg);
            -moz-transform: rotate(360deg);
            -ms-transform: rotate(360deg);
            -o-transform: rotate(360deg);
            transform: rotate(360deg);
        }
    }
    @-moz-keyframes spinner {
        0% {
            -webkit-transform: rotate(0deg);
            -moz-transform: rotate(0deg);
            -ms-transform: rotate(0deg);
            -o-transform: rotate(0deg);
            transform: rotate(0deg);
        }
        100% {
            -webkit-transform: rotate(360deg);
            -moz-transform: rotate(360deg);
            -ms-transform: rotate(360deg);
            -o-transform: rotate(360deg);
            transform: rotate(360deg);
        }
    }
    @-o-keyframes spinner {
        0% {
            -webkit-transform: rotate(0deg);
            -moz-transform: rotate(0deg);
            -ms-transform: rotate(0deg);
            -o-transform: rotate(0deg);
            transform: rotate(0deg);
        }
        100% {
            -webkit-transform: rotate(360deg);
            -moz-transform: rotate(360deg);
            -ms-transform: rotate(360deg);
            -o-transform: rotate(360deg);
            transform: rotate(360deg);
        }
    }
    @keyframes spinner {
        0% {
            -webkit-transform: rotate(0deg);
            -moz-transform: rotate(0deg);
            -ms-transform: rotate(0deg);
            -o-transform: rotate(0deg);
            transform: rotate(0deg);
        }
        100% {
            -webkit-transform: rotate(360deg);
            -moz-transform: rotate(360deg);
            -ms-transform: rotate(360deg);
            -o-transform: rotate(360deg);
            transform: rotate(360deg);
        }
    }
}
</style>
