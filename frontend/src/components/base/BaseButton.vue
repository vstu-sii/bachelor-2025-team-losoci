<script setup>
defineOptions({
    name: "BaseButton",
})

const props = defineProps({
    type: {
        type: String,
        default: "button",
    },
    text: {
        type: String,
        required: true,
    },
    variant: {
        type: String,
        default: "solid",
    },
    color: {
        type: String,
        default: "primary",
    },
})
</script>

<template>
    <button
        :class="['button', `button--${color}`, `button--${variant}`]"
        :type="type"
    >
        {{ text }}
    </button>
</template>

<style lang="scss" scoped>
.button {
    padding: 1em 0.5em;
    width: 100%;
    max-height: 100px;
    font-size: 2rem;
    font-family: var(--Inter);
    color: var(--white);
    font-weight: 700;
    background: linear-gradient(-60deg, #3500ea, #706dff, #ba84ef);
    background-size: 200% 200%;
    background-position: 10% 50%;
    border-radius: 12px;
    transition: 0.25s all ease-in-out;

    &:hover {
        background-position: 100% 50%;
    }

    &:active {
        background-color: var(--black);
        color: var(--white);
    }

    &--outlined {
        background-color: var(--white);
        color: var(--black);

        &:hover {
            background-color: var(--black);
            color: var(--white);
        }

        &:active {
            background-color: var(--white);
            color: var(--black);
        }
    }

    @include wide {
        font-size: 1.8rem;
    }
}
</style>
