<script setup>
const modelValue = defineModel();

const emit = defineEmits(['image-click']);

const props = defineProps({
    type: {
        type: String,
        default: 'text',
    },
    placeholder: {
        type: String,
        required: true,
    },
    title: {
        type: String,
        required: true,
    },
    disabled: {
        type: Boolean,
        default: false,
    },
    image: {
        type: String,
        default: '',
    },
    id: {
        type: String,
        default: '',
    },
});
</script>

<template>
    <div class="input_with_title">
        <span class="input_with_title__title">{{ title }}</span>
        <BaseInput
            :type="type"
            :placeholder="placeholder"
            v-model="modelValue"
            :disabled="disabled"
            :image="image"
            :id="id"
            @image-click="emit('image-click')"
        />
    </div>
</template>

<style lang="scss" scoped>
.input_with_title {
    display: flex;
    flex-direction: column;
    gap: 12px;

    &__title {
        margin: 0em 1em;
        font-size: 1.5rem;
        font-family: var(--Inter);
        line-height: 1.2;
        color: var(--placeholder-color);

        @include wide {
            color: var(--text-color);
        }

        @include wide {
            font-size: 1.3rem;
        }

        @include desktop {
            font-size: 1.2rem;
        }

        @include laptop {
            font-size: 1.5rem;
        }
    }
}
</style>
