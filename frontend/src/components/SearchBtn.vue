<script setup>
import { ref, computed, nextTick } from "vue"
import Search from "@/assets/svg/Search.svg"
import Close from "@/assets/svg/Close.svg"

const searchQuery = defineModel("query", { default: "" })
const isEditing = ref(false)
const inputRef = ref(null)

const showClear = computed(() => isEditing.value && searchQuery.value)

function startEditing() {
    isEditing.value = true
    nextTick(() => inputRef.value.focus())
}

function handleBlur() {
    if (!searchQuery.value.trim()) {
        isEditing.value = false
    }
}

function handleEsc() {
    searchQuery.value = ""
    isEditing.value = false
    inputRef.value?.blur()
}

function clear() {
    searchQuery.value = ""
    isEditing.value = false
}
</script>

<template>
    <div
        class="search-btn"
        :class="{ 'search-btn--active': isEditing || searchQuery }"
        @dblclick.prevent="startEditing"
    >
        <img :src="Search" class="search-btn__icon" />

        <span v-if="!isEditing" class="search-btn__placeholder">
            Поиск в чатах
        </span>

        <input
            v-else
            v-model="searchQuery"
            @blur="handleBlur"
            @keydown.esc="handleEsc"
            placeholder="Поиск в чатах..."
            class="search-btn__input"
            ref="inputRef"
        />

        <button v-if="showClear" @click.stop="clear" class="search-btn__clear">
            <img :src="Close" />
        </button>
    </div>
</template>

<style lang="scss" scoped>
.search-btn {
    position: relative;
    padding: 12px;
    display: flex;
    align-items: center;
    gap: 12px;
    border-radius: 20px;
    background: transparent;
    transition: all 0.25s ease;
    cursor: default;
    user-select: none;
    z-index: 0;

    &::before {
        content: "";
        position: absolute;
        inset: 0;
        border-radius: inherit;
        background: linear-gradient(-140deg, #3500ea, #706dff, #ba84ef);
        opacity: 0;
        transition: opacity 0.25s ease;
        z-index: -1;
    }

    &:hover::before,
    &--active::before {
        opacity: 1;
    }

    &__icon {
        width: 40px;
        height: 40px;
        color: var(--placeholder-color);
        transition: color 0.25s;
        flex-shrink: 0;
    }

    &:hover &__icon,
    &--active &__icon {
        color: var(--white);
    }

    &__placeholder {
        font-size: 20px;
        font-family: var(--Inter);
        font-weight: 700;
        color: var(--placeholder-color);
        transition: color 0.25s;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: calc(100% - 60px);
    }

    &--active &__placeholder,
    &:hover &__placeholder {
        color: var(--white);
    }

    &__input {
        position: absolute;
        left: 60px;
        right: 48px;
        top: 50%;
        transform: translateY(-50%);
        background: transparent;
        border: none;
        color: var(--white);
        font-size: 20px;
        font-family: var(--Inter);
        font-weight: 700;
        width: calc(100% - 108px);
        outline: none;
        z-index: 2;

        &::placeholder {
            color: var(--placeholder-color);
        }
    }

    &__clear {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        width: 28px;
        height: 28px;
        padding: 0;
        cursor: pointer;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.25s;

        svg {
            width: 100%;
            height: 100%;
            color: var(--white);
        }
    }

    &--active &__clear {
        opacity: 1;
        pointer-events: auto;
    }
}
</style>
