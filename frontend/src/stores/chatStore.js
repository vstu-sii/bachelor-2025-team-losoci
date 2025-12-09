import { ref } from "vue"
import { defineStore } from "pinia"
import ChatService from "@/services/ChatService"

export const useChatStore = defineStore("chat", () => {
    const chats = ref([])
    const currentChatId = ref(null)

    async function loadChats() {
        try {
            const response = await ChatService.getChats()
            chats.value = response.data.map((chat) => ({
                ...chat,
                editing: false,
            }))
        } catch (error) {
            console.error("Failed to load chats:", error)
            chats.value = []
        }
    }

    function addChat(chat) {
        const exists = chats.value.some((c) => c.id === chat.id)
        if (!exists) {
            chats.value.unshift({
                ...chat,
                editing: false,
            })
        }
    }

    function removeChat(chatId) {
        chats.value = chats.value.filter((c) => c.id !== chatId)
        if (currentChatId.value === chatId) {
            currentChatId.value = null
        }
    }

    function setCurrentChat(id) {
        currentChatId.value = id
    }

    return {
        chats,
        currentChatId,
        loadChats,
        addChat,
        removeChat,
        setCurrentChat,
    }
})
