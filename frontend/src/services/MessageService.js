import ApiServise from "@/services/ApiServise"

class MessageService {
    static async getMessages(chatId) {
        const response = await ApiServise.get(`/message/${chatId}`)
        return response
    }

    static async sendMessage(data) {
        const response = await ApiServise.post("/message/stream", data)
        return response
    }
}

export default MessageService
