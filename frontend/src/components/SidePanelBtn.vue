<script setup>
const props = defineProps({
    image: {
        type: String,
        required: true,
    },
    text: {
        type: String,
        required: true,
    },
})
</script>

<template>
    <button class="button">
        <img class="button__img" :src="image" :alt="text" />
        <span class="button__text">{{ text }}</span>
    </button>
</template>

<style lang="scss" scoped>
.button {
    position: relative;
    padding: 12px;
    display: flex;
    align-items: center;
    gap: 12px;
    border-radius: 20px;
    z-index: 0;

    &:hover {
        .button__text {
            color: var(--white);
        }
    }

    &::before {
        content: "";
        position: absolute;
        inset: 0;
        z-index: 1;
        border-radius: inherit;
        background: linear-gradient(
            -140deg,
            rgba(53, 0, 234, 1),
            rgba(112, 109, 255, 1),
            rgba(186, 132, 239, 1)
        );
        opacity: 0;
        transition: opacity 0.25s ease-in-out;
        pointer-events: none;
    }

    &:hover::before {
        opacity: 1;
    }

    &__img {
        width: 40px;
        height: 40px;
        z-index: 2;
    }

    &__text {
        font-size: 20px;
        font-family: var(--Inter);
        color: var(--placeholder-color);
        font-weight: 700;
        z-index: 2;
        transition: 0.25s all ease-in-out;
    }
}
</style>
