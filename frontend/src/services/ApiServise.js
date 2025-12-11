import axios from "axios"
import router from "@/router"

class ApiService {
    api
    isRefreshing = false
    failedQueue = []

    constructor(baseURL) {
        this.api = axios.create({
            baseURL,
            withCredentials: true,
        })

        this.api.interceptors.request.use((config) => {
            const token = localStorage.getItem("accessToken")
            if (token) {
                config.headers.Authorization = `Bearer ${token}`
            }
            return config
        })

        this.api.interceptors.response.use(
            (response) => response,
            (error) => {
                const originalRequest = error.config

                if (error.response?.status === 401 && !originalRequest._retry) {
                    originalRequest._retry = true

                    const retryOriginalRequest = new Promise(
                        (resolve, reject) => {
                            this.subscribeTokenRefresh((token) => {
                                if (!token) {
                                    reject(error)
                                    return
                                }
                                originalRequest.headers.Authorization = `Bearer ${token}`
                                resolve(this.api(originalRequest))
                            })
                        }
                    )

                    if (!this.isRefreshing) {
                        this.isRefreshing = true
                        this.api
                            .get("/token/refresh")
                            .then(({ data }) => {
                                const newToken =
                                    data?.data?.accessToken || data?.accessToken
                                if (!newToken)
                                    throw new Error("No access token")
                                localStorage.setItem("accessToken", newToken)
                                this.onRefreshed(newToken)
                            })
                            .catch((err) => {
                                this.onRefreshFailed()
                                this.logout()
                            })
                            .finally(() => {
                                this.isRefreshing = false
                            })
                    }

                    return retryOriginalRequest
                }

                return Promise.reject(error)
            }
        )
    }

    subscribeTokenRefresh(callback) {
        this.failedQueue.push(callback)
    }

    onRefreshed(token) {
        this.failedQueue.forEach((cb) => cb(token))
        this.failedQueue = []
    }

    onRefreshFailed() {
        this.failedQueue.forEach((cb) => cb(null))
        this.failedQueue = []
    }

    logout() {
        localStorage.removeItem("accessToken")
        delete this.api.defaults.headers.common.Authorization
        if (router.currentRoute.value.path === "/") return
        router.push("/authorization")
    }

    get instance() {
        return this.api
    }

    async get(url) {
        const response = await this.api.get(url)
        return response.data
    }

    async post(url, data) {
        const response = await this.api.post(url, data)
        return response.data
    }

    async put(url, data) {
        const response = await this.api.put(url, data)
        return response.data
    }

    async patch(url, data) {
        const response = await this.api.patch(url, data)
        return response.data
    }

    async delete(url) {
        const response = await this.api.delete(url)
        return response.data
    }
}

export default new ApiService(import.meta.env.VITE_SERVER_URL)
