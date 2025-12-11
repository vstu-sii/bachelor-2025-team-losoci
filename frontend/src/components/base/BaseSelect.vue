<script setup>
import { ref } from "vue"
import { onClickOutside } from "@vueuse/core"
import SelectArrow from "@/assets/icons/ISelectArrow.vue"

defineOptions({
    name: "BaseSelect",
})

const target = ref(null)

const modelSelected = defineModel()
const emit = defineEmits(["select-event"])

const props = defineProps({
    options: {
        type: Array,
        required: true,
    },
    disabled: {
        type: Boolean,
        default: false,
    },
})

const isVisible = ref(false)

function changeVisibility() {
    if (props.disabled) return
    isVisible.value = !isVisible.value
}

onClickOutside(target, () => (isVisible.value = false))

function selectOption(option) {
    modelSelected.value = option
    isVisible.value = false

    emit("select-event", option)
}
</script>

<template>
    <div ref="target" class="select" @click="changeVisibility">
        <div
            :class="[
                'select__current',
                { 'select__current--disabled': disabled },
            ]"
        >
            <span class="select__text">{{
                modelSelected || "Выберите опцию"
            }}</span>
            <SelectArrow
                class="select__arrow"
                :class="{ 'select__arrow--rotated': isVisible }"
            />
        </div>
        <ul class="select__options" v-if="isVisible">
            <li
                v-for="(option, index) in options"
                class="select__option"
                :key="index"
                @click.stop="selectOption(option)"
            >
                {{ option }}
            </li>
        </ul>
    </div>
</template>

<style lang="scss" scoped>
.select {
    position: relative;
    user-select: none;

    &__current {
        padding: 1.25em;
        max-height: 90px;
        font-size: 1.5rem;
        font-family: var(--Inter);
        color: var(--white);
        border-radius: 20px;
        border: 1px solid var(--white);
        transition: background-color 0.3s ease-in-out, color 0.3s ease-in-out;
        display: flex;
        justify-content: space-between;
        cursor: pointer;

        &:hover {
            color: var(--placeholder-color);
        }

        &--disabled {
            cursor: default;
            &:hover {
                color: var(--white);
            }
        }
    }

    &__text {
        width: 100%;
    }

    &__options {
        padding: 8px 0px;
        margin-top: 4px;
        position: absolute;
        top: 100%;
        width: 100%;
        text-align: center;
        border-radius: 12px;
        overflow: hidden;
        background-color: rgb(36, 36, 36);
        z-index: 1;
    }

    &__option {
        padding: 12px 0px;
        font-size: 16px;
        font-weight: 600;
        font-family: var(--Inter);
        line-height: 1.33;
        color: var(--white);
        cursor: pointer;

        &:hover {
            background-color: rgb(49, 49, 49);
            color: var(--white);
        }
    }

    &__arrow {
        transition: transform 0.2s ease-in-out;
        transform: rotate(90deg);
    }

    &__arrow--rotated {
        transform: rotate(270deg);
    }
}
</style>
