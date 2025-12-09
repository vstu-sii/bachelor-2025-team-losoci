<script setup>
import { ref, computed } from "vue"

defineOptions({
    name: "MusicPlayer",
})

const bgMusic = ref(null)
const isPlaying = ref(false)

const status = computed(() => (isPlaying.value ? "playing" : "paused"))

const startMusic = async () => {
    if (!isPlaying.value && bgMusic.value) {
        try {
            bgMusic.value.volume = 0.1
            await bgMusic.value.play()
            isPlaying.value = true
        } catch (err) {
            console.log(err)
        }
    }
}

document.addEventListener(
    "click",
    () => {
        startMusic()
    },
    { once: true }
)
</script>

<template>
    <audio ref="bgMusic" src="./Shaman_Russkiy.mp3" loop preload="auto"></audio>
</template>
