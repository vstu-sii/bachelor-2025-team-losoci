// middlewares/fetchCheck.ts
import router from "@/router"

export async function fetchWithAuthStream(url, options = {}, maxRetries = 1) {
    const token = localStorage.getItem("accessToken")

    const authHeaders = token ? { Authorization: `Bearer ${token}` } : {}

    const fetchOptions = {
        ...options,
        headers: {
            ...options.headers,
            ...authHeaders,
        },

        signal: options.signal,
        credentials: options.credentials || "include",
    }
    console.log(716253)
    const response = await fetch(url, fetchOptions)
    console.log(await response.json())
    if (response.status === 401 && maxRetries > 0) {
        try {
            const refreshRes = await fetch(
                `${import.meta.env.VITE_SERVER_URL}/token/refresh`,
                {
                    method: "GET",
                    credentials: "include",
                }
            )

            if (!refreshRes.ok) throw new Error("Refresh failed")

            const data = await refreshRes.json()
            const newToken = data?.data?.accessToken || data?.accessToken
            if (!newToken) throw new Error("No new token")

            localStorage.setItem("accessToken", newToken)

            return fetchWithAuthStream(
                url,
                {
                    ...options,
                    headers: {
                        ...options.headers,
                        Authorization: `Bearer ${newToken}`,
                    },
                    signal: options.signal,
                },
                maxRetries - 1
            )
        } catch (err) {
            console.error("Token refresh failed:", err)
            logout()
            throw err
        }
    }

    if (response.status === 401) {
        logout()
        throw new Error("Unauthorized")
    }

    return response
}

function logout() {
    localStorage.removeItem("accessToken")
    router.push("/authorization")
}
