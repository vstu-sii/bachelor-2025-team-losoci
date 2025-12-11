<script setup>
const emit = defineEmits(["aprove-warning-message", "close-warning-message"])

const props = defineProps({
    message: {
        type: String,
        required: true,
    },
    title: {
        type: String,
        required: true,
    },
    btn1Title: {
        type: String,
        required: true,
    },
    btn2Title: {
        type: String,
        required: true,
    },
})
</script>

<template>
    <div class="warning_message">
        <h2 class="warning_message__title">{{ title }}</h2>
        <p class="warning_message__message">{{ message }}</p>
        <div class="warning_message__btns">
            <button
                type="button"
                class="warning_message__btns__btn2"
                @click="emit('close-warning-message')"
            >
                {{ btn2Title }}</button
            ><button
                type="button"
                class="warning_message__btns__btn1"
                @click="emit('aprove-warning-message')"
            >
                {{ btn1Title }}
            </button>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.warning_message {
    padding: 24px;
    max-width: 400px;
    width: 100%;

    background-color: rgb(49, 49, 49);
    box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.15);
    border-radius: 20px;
    display: flex;
    flex-direction: column;
    gap: 20px;
    z-index: 1;

    &__title {
        font-size: 32px;
        font-weight: 700;
        text-align: center;
        color: var(--white);
        font-family: var(--Inter);
    }

    &__message {
        font-size: 16px;
        line-height: 1.5;
        text-align: center;
        color: var(--text-color);
        font-family: var(--Inter);
    }

    &__btns {
        display: flex;
        justify-content: center;
        gap: 16px;
    }

    &__btns__btn1 {
        flex-grow: 1;
        padding: 8px 20px;
        border-radius: 12px;
        background-color: var(--red);
        font-size: 16px;
        font-weight: 600;
        color: var(--white);
        font-family: var(--Inter);
        transition: .2s all ease-in-out;

        &:hover {
            background: #b40d0d;
        }
    }

    &__btns__btn2 {
        flex-grow: 1;
        padding: 8px 16px;
        border-radius: 12px;
        background-color: #464646;
        border: 1px solid #b3b3b3;
        font-size: 16px;
        font-weight: 600;
        color: var(--white);
        font-family: var(--Inter);

        transition: .2s all ease-in-out;

        &:hover {
            background: #2e2e2e;
        }
    }
}
</style>
