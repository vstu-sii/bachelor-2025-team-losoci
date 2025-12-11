import ApiServise from "./ApiServise"

export class EventService {
    static async getEventById(id) {
        const response = await ApiServise.get(`/event/${id}`)
        return response
    }

    static async getUserEvents(limit, offset, date) {
        const response = await ApiServise.get(
            `/event/?limit=${limit}&offset=${offset}&date=${date}`
        )
        return response
    }

    static async createEvent(data) {
        const response = await ApiServise.post(`/event`, data)
        return response
    }

    static async updateEvent(data) {
        const response = await ApiServise.put(`/event`, data)
        return response
    }

    static async deleteEvent(id) {
        const response = await ApiServise.delete(`/event/${id}`)
        return response
    }
}
