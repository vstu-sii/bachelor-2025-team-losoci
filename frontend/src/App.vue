<script setup>
import { ref } from "vue"
import MusicPlayer from "./components/MusicPlayer.vue"

const token = localStorage.getItem("accessToken")
const responseText = ref("")


//sendMessage(3, "123", 28, 28)
</script>

<template>
    <router-view></router-view>
    {{ responseText }}
    <!--<MusicPlayer />-->
</template>

<style scoped></style>
