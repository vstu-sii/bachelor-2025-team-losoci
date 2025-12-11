<script setup>
import { useRouter } from "vue-router"
import LogoAndTitle from "@/components/LogoAndTitle.vue"

const router = useRouter()
</script>

<template>
    <div class="auth_layout">
        <div class="auth_layout__ellipse"></div>
        <div class="auth_layout__left_container">
            <LogoAndTitle />
            <h2 class="auth_layout__left_container__subtitle">
                Подарки, подобранные интеллектом
            </h2>
        </div>
        <main class="auth_layout__main">
            <slot />
        </main>
    </div>
</template>

<style lang="scss" scoped>
.auth_layout {
    padding: clamp(30px, 6.25vh, 100px);
    display: flex;
    justify-content: space-between;
    align-items: stretch;
    min-height: 100dvh;
    width: 100%;
    background: rgba(23, 24, 26, 0.97);

    position: relative;
    z-index: 0;

    @include laptop {
        justify-content: center;
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

    &__ellipse {
        position: absolute;
        top: 0px;
        left: 0px;
        width: 100%;
        height: 100%;
        background-image: url("/ellipse.svg");
        background-repeat: no-repeat;
        background-position: top left;
        background-attachment: scroll;
        background-origin: padding-box;
        background-clip: border-box;
        z-index: 0;
    }

    &__left_container {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        z-index: 1;
        width: 100%;
        max-width: 1000px;
        max-height: 87.5vh;

        &__subtitle {
            font-size: 7rem;
            font-weight: 700;
            font-family: var(--Montserrat);
            line-height: 1.2;
            color: var(--white);

            @include desktop {
                font-size: 4rem;
            }
        }

        @include laptop {
            display: none;
        }
    }

    &__main {
        z-index: 1;
        width: 100%;
        max-width: 575px;

        @include laptop {
            padding: 3em;
            position: relative;
            z-index: 1;
            width: 100%;

            position: relative;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(3px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.4);
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.3),
                inset 0 4px 20px rgba(255, 255, 255, 0.2);
            border-radius: 24px;

            &::after {
                content: "";
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(255, 255, 255, 0.01);
                border-radius: 24px;
                backdrop-filter: blur(1px);
                box-shadow: inset -10px -8px 0px -11px rgba(255, 255, 255, 0.4),
                    inset 0px -9px 0px -8px rgba(255, 255, 255, 0.1);
                opacity: 0.6;
                z-index: -1;
                filter: blur(1px) drop-shadow(10px 4px 6px black)
                    brightness(85%);
            }
        }
    }
}
</style>
