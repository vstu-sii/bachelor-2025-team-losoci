import { createApp } from "vue"
import { createPinia } from "pinia"

import "./assets/main.scss"
import "./assets/styles/reset.css"
import "./assets/styles/fonts.css"

import App from "./App.vue"
import router from "./router"

import components from "./components"

const app = createApp(App)
const pinia = createPinia()

components.forEach((component) => {
    app.component(component.name, component)
})

app.use(pinia)
app.use(router)

app.mount("#app")
