<script setup>
import { useRouter } from "vue-router"

import LogoAndTitle from "@/components/LogoAndTitle.vue"

const isAuthorized = localStorage.getItem("accessToken") !== null

const router = useRouter()
</script>

<template>
    <div class="home">
        <div class="home__ellipse"></div>
        <div class="home__sidepanel">
            <slot name="sidePanel" v-if="isAuthorized"></slot>
        </div>
        <main class="home__main">
            <header class="home__header" v-if="!isAuthorized">
                <logo-and-title />
                <BaseButton
                    class="home__login-button"
                    v-if="!isAuthorized"
                    text="Войти"
                    @click="router.push('/authorization')"
                ></BaseButton>
            </header>
            <slot></slot>
        </main>
    </div>
</template>

<style lang="scss" scoped>
.home {
    padding: 40px;
    display: flex;
    justify-content: space-between;
    min-height: 100dvh;
    width: 100%;
    background: rgba(23, 24, 26, 0.97);

    position: relative;
    z-index: 0;

    @include laptop {
        padding: 32px;
    }

    @include tablet {
        padding: 24px;
    }

    @include mobile {
        padding: 16px;
    }

    &::before {
        content: "";
        position: absolute;
        inset: 0;
        background: rgba(255, 255, 255, 0.04);
        pointer-events: none;
        z-index: 0;
        mix-blend-mode: overlay;
    }

    &__header {
        position: fixed;
        width: calc(100% - 80px);
        top: 44px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 40px;
        z-index: 2;

        @include tablet {
            width: calc(100% - 40px);
            left: 20px;
            top: 22px;
            gap: 20px;
        }

        @include mobile {
            width: calc(100% - 40px);
            top: 20px;
            gap: 20px;
        }
    }

    &__login-button {
        max-width: 360px;
        z-index: 3;

        @include tablet {
            max-width: 240px;
        }

        @include mobile {
            max-width: 180px;
        }
    }

    &__ellipse {
        background: rgba(23, 24, 26, 1);
        position: fixed;
        bottom: 0px;
        left: 0px;
        width: 100%;
        height: 100%;
        max-height: 100dvh;
        background-image: url("/ellipse2.svg");
        background-repeat: no-repeat;
        background-position: bottom left;
        background-attachment: scroll;
        background-origin: padding-box;
        background-clip: border-box;
        background-size: contain;
        z-index: 0;
    }

    &__main {
        z-index: 1;
        width: 100%;

        @include desktop {
            margin-left: 48px;
        }
    }

    &__sidepanel {
        position: fixed;
        padding: 24px 0px;
        z-index: 2;
        height: calc(100vh - 80px);
        background: #1a1a1a;
        border-radius: 24px;

        @include laptop {
            height: calc(100vh - 64px);
        }

        @include tablet {
            height: calc(100vh - 48px);
        }

        @include mobile {
            height: calc(100vh - 32px);
        }
    }
}
</style>
