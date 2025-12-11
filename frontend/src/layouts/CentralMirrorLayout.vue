<script setup></script>

<template>
    <div class="central_mirror">
        <div class="central_mirror__ellipse"></div>
        <main class="central_mirror__main">
            <slot />
        </main>
    </div>
</template>

<style lang="scss" scoped>
.central_mirror {
    padding: clamp(30px, 6.25vh, 100px);
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100dvh;
    width: 100%;
    background: rgba(23, 24, 26, 0.97);
    position: relative;
    z-index: 0;

    &::before {
        content: "";
        position: absolute;
        inset: 0;
        pointer-events: none;
        background: rgba(255, 255, 255, 0.04);
        z-index: 0;
        mix-blend-mode: overlay;
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
        max-width: 575px;

        padding: 1em;
        position: relative;
        z-index: 1;
        width: 100%;

        position: relative;
        background: rgba(255, 255, 255, 0.04);
        backdrop-filter: blur(3px) saturate(130%);
        border: 1px solid rgba(255, 255, 255, 0.4);
        box-shadow: 0 8px 32px rgba(67, 68, 75, 0.3),
            inset 0 4px 20px rgba(255, 255, 255, 0.2);
        border-radius: 24px;

        &::after {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.15);
            border-radius: 24px;
            backdrop-filter: blur(1px);
            box-shadow: inset -10px -8px 0px -11px rgba(255, 255, 255, 0.4),
                inset 0px -9px 0px -8px rgba(255, 255, 255, 0.1);
            opacity: 0.6;
            z-index: -1;
            filter: blur(1px) drop-shadow(10px 4px 6px black) brightness(85%);
        }
    }
}
</style>
