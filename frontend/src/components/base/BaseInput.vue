<script setup>
defineOptions({
    name: "BaseInput",
})

const modelValue = defineModel()

const emit = defineEmits(["image-click", "image2-click"])

const props = defineProps({
    type: {
        type: String,
        default: "text",
    },
    placeholder: {
        type: String,
        required: true,
    },
    disabled: {
        type: Boolean,
        default: false,
    },
    image: {
        type: String,
        default: "",
    },
    image2: {
        type: String,
        default: "",
    },
    id: {
        type: String,
        default: "",
    },
})
</script>

<template>
    <div class="input__wrapper">
        <input
            :class="['input', { 'input--image2': image2 }]"
            v-model="modelValue"
            :type="type"
            :placeholder="placeholder"
            :id="id"
            :disabled="disabled"
        />
        <img
            class="input__second_image"
            v-if="image2"
            :src="image2"
            @mousedown.prevent
            @click="emit('image2-click')"
        />
        <img
            v-if="image"
            class="input__image"
            :src="image"
            @mousedown.prevent
            @click="emit('image-click')"
        />
    </div>
</template>

<style lang="scss" scoped>
.input {
    padding: 1em;
    width: 100%;
    font-size: 1.5rem;
    line-height: 1;
    font-family: var(--Inter);
    color: var(--text-color);
    border-radius: 20px;

    &--image2 {
        padding-right: 130px;
    }

    &::placeholder {
        color: var(--placeholder-color);

        @include wide {
            color: var(--text-color);
        }
    }

    &__wrapper {
        padding: 3em 1em;
        max-height: 90px;
        position: relative;
        width: 100%;
        display: flex;
        align-items: center;
        border: 1px solid var(--white);
        border-radius: 20px;

        @include wide {
            padding: 2.5em 1em;
        }

        @include desktop {
            padding: 2.3em 1em;
        }

        @include laptop {
            padding: 3em 1em;
        }

        @include tablet {
            padding: 1.5em 1em;
        }

        @include mobile {
            padding: 1em 1em;
        }
    }

    &__image {
        position: absolute;
        top: 50%;
        right: 30px;
        transform: translateY(-50%);
        z-index: 1;
        cursor: pointer;

        @include desktop {
            right: 12px;
        }

        @include laptop {
            right: 12px;
        }
    }

    &__second_image {
        position: absolute;
        height: 60px;
        width: 60px;
        border-radius: 50%;
        top: 50%;
        right: 84px;
        transform: translateY(-50%);
        z-index: 1;
        cursor: pointer;
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
</style>
