import ApiService from "@/services/ApiServise"

class ChatService {
    static async getChats() {
        const response = await ApiService.get("/chat")
        return response
    }

    static async openChat(chatId) {
        const response = await ApiService.get(`/chat/${chatId}`)
        return response
    }

    static async createChat(data) {
        const response = await ApiService.post(`/chat`, data)
        return response
    }

    static async updateChat(data) {
        const response = await ApiService.put(`/chat`, data)
        return response
    }

    static async addRecipient(chatId, data) {
        const response = await ApiService.patch(`/chat/${chatId}`, data)
        return response
    }

    static async deleteChat(chatId) {
        const response = await ApiService.delete(`/chat/${chatId}`)
        return response
    }
}

export default ChatService
