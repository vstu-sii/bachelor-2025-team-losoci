import { defineStore } from "pinia"
import { ref } from "vue"

export const useUserStore = defineStore("user", () => {
    const email = ref("")

    const setEmail = (newEmail) => {
        email.value = newEmail
    }

    const clearEmail = () => {
        email.value = ""
    }

    return {
        email,
        setEmail,
        clearEmail,
    }
})
