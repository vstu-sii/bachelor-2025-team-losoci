<script setup>
import IGiftIcon from '@/assets/icons/IGiftIcon.vue';
</script>

<template>
    <div class="logo_title">
        <IGiftIcon class="logo_title__icon" />
        <h1 class="logo_title__title">Ai Gift Assistant</h1>
    </div>
</template>

<style lang="scss" scoped>
.logo_title {
    display: flex;
    align-items: center;
    gap: 24px;

    &__icon:hover {
        animation: rotateGift 0.8s linear;
    }

    @keyframes rotateGift {
        0% {
            transform: rotate(0deg) translateY(0px) translateX(0px);
        }
        10% {
            transform: rotate(15deg) translateY(-10px) translateX(10px);
        }
        20% {
            transform: rotate(0deg) translateY(-15px) translateX(0px);
        }
        30% {
            transform: rotate(-15deg) translateY(-20px) translateX(-10px);
        }
        40% {
            transform: rotate(0deg) translateY(-30px) translateX(10px);
        }
        50% {
            transform: rotate(-15deg) translateY(-30px) translateX(0px);
        }
        60% {
            transform: rotate(0deg) translateY(-20px) translateX(-10px);
        }
        80% {
            transform: rotate(15deg) translateY(-10px) translateX(10px);
        }
        100% {
            transform: rotate(0deg) translateY(0px) translateX(0px);
        }
    }

    &__title {
        font-size: 2.375rem;
        font-weight: 700;
        font-family: var(--Montserrat);
        line-height: 1.2;
        color: var(--white);
        max-width: 188px;
    }
}
</style>
