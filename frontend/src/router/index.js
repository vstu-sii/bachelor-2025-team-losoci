import { createRouter, createWebHistory } from "vue-router"

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            component: () => import("@/views/HomePage.vue"),
        },
        {
            path: "/:chatId",
            component: () => import("@/views/HomePage.vue"),
        },
        {
            path: "/authorization",
            component: () => import("../views/AuthorizationPage.vue"),
        },
        {
            path: "/registration",
            component: () => import("@/views/RegistrationPage.vue"),
        },
        {
            path: "/email-confirmation",
            component: () => import("@/views/EmailConfirmationPage.vue"),
        },
        {
            path: "/email-success",
            component: () => import("@/views/EmailSuccessPage.vue"),
        },
        {
            path: "/profile",
            component: () => import("@/views/ProfilePage.vue"),
        },
        {
            path: "/email-recover",
            component: () => import("@/views/EmailPasswordForgotPage.vue"),
        },
        {
            path: "/email-reset",
            component: () => import("@/views/EmailPasswordResetPage.vue"),
        },
        {
            path: "/email-recover-success",
            component: () => import("@/views/EmailResetMessagePage.vue"),
        },
        {
            path: "/events",
            component: () => import("@/views/EventsPage.vue"),
        },
    ],
})

export default router
