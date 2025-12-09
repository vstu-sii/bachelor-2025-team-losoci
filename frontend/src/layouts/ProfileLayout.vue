<script setup></script>

<template>
    <div class="profile_layout">
        <div class="profile_layout__ellipse"></div>
        <div class="profile_layout__sidepanel">
            <slot name="sidePanel"></slot>
        </div>
        <main class="profile_layout__main">
            <slot></slot>
        </main>
    </div>
</template>

<style lang="scss" scoped>
.profile_layout {
    padding: 40px;
    display: flex;
    justify-content: space-between;
    min-height: 100dvh;
    width: 100%;
    background: rgba(23, 24, 26, 0.97);

    position: relative;
    z-index: 0;

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
        background: rgba(23, 24, 26, 1);
        position: fixed;
        bottom: 0px;
        left: 0px;
        width: 100%;
        height: 100%;
        max-height: 100vh;
        background-image: url("/ellipse3.svg");
        background-repeat: no-repeat;
        background-position: bottom right;
        background-attachment: scroll;
        background-origin: padding-box;
        background-clip: border-box;
        background-size: contain;
        z-index: 0;
    }

    &__main {
        z-index: 1;
        width: 100%;
        display: flex;
        justify-content: center;
    }

    &__sidepanel {
        padding: 24px 0px;
        max-width: 368px;
        z-index: 2;
        height: calc(100vh - 80px);
        background-color: #1a1a1a;
        border-radius: 24px;
    }
}
</style>
