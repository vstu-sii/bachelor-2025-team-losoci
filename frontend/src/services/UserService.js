import ApiService from "@/services/ApiServise"

class UserService {
    static async login(data) {
        const response = await ApiService.post("/user/login", data)
        localStorage.setItem("accessToken", response.data.accessToken)
        return response
    }

    static async createUser(data) {
        const response = await ApiService.post("/user/register", data)
        return response
    }

    static async searchUser(data) {
        const response = await ApiService.get(
            "/user/search/?username=" + data.username + "&email=" + data.email
        )
        return response
    }

    static async verifyEmail(token) {
        const response = await ApiService.patch(`/user/verify-email`)
        localStorage.setItem("accessToken", response.data.accessToken)
        return response
    }

    static async updateUser(data) {
        const response = await ApiService.put("/user", data)
        return response
    }

    static async updatePhoto(data) {
        const response = await ApiService.post("/photo/upload", data)
        return response
    }

    static async getUser() {
        const response = await ApiService.get("/user/me")
        return response
    }

    static async logout() {
        const response = await ApiService.post("/user/logout")
        localStorage.removeItem("accessToken")
        return response
    }

    static async deleteUser() {
        const response = await ApiService.delete("/user")
        localStorage.removeItem("accessToken")
        return response
    }

    static async resetPassword(data) {
        const response = await ApiService.post("/user/reset-password", data)
        return response
    }

    static async updatePassword(token, data) {
        localStorage.setItem("accessToken", token)
        const response = await ApiService.patch("/user/password", data)
        return response
    }

    static async getUserPhoto(userId) {
        const response = await ApiService.get(`/photo/${userId}`)
        return response
    }
}

export default UserService
