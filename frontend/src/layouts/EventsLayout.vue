<script setup>
import EventDay from "@/components/EventDay.vue"
import { ref, onMounted } from "vue"
import { useInfiniteScroll } from "@vueuse/core"
import { EventService } from "@/services/EventService"

const events = ref([])

const today = ref("")
const todayFullDate = ref("")
const limit = 10
const offset = ref(0)
const loadingMore = ref(false)
const containerRef = ref(null)

function getTodayInfo() {
    const now = new Date()

    const weekday = now.toLocaleDateString("ru-RU", { weekday: "long" })
    const formattedDate = now.toLocaleDateString("ru-RU", {
        day: "numeric",
        month: "long",
        year: "numeric",
    })

    today.value = weekday.charAt(0).toUpperCase() + weekday.slice(1)
    todayFullDate.value = formattedDate
}

function restructureEvents(eventsData) {
    const grouped = {}

    for (const e of eventsData) {
        if (!grouped[e.date]) {
            grouped[e.date] = []
        }
        grouped[e.date].push({
            id: e.id,
            title: e.title,
            description: e.description,
            date: e.date,
            importance_id: e.importance_id,
            completed: e.completed,
            user_id: e.user_id,
            recipient_id: e.recipient_id,
            userName: e.userName || "",
        })
    }

    return Object.keys(grouped)
        .sort((a, b) => new Date(a).getTime() - new Date(b).getTime())
        .map((date) => ({
            date,
            events: grouped[date],
        }))
}

async function loadEvents(offsetVal = 0, append = false) {
    if (loadingMore.value) return
    loadingMore.value = true
    try {
        const response = await EventService.getUserEvents(limit, offsetVal)
        const rawEvents = response.data || []
        const grouped = restructureEvents(rawEvents)

        if (append) {
            events.value.push(...grouped)
        } else {
            events.value = grouped
        }

        offset.value += limit
    } catch (error) {
        console.error("Ошибка загрузки событий:", error)
    } finally {
        loadingMore.value = false
    }
}

useInfiniteScroll(containerRef, () => loadEvents(offset.value, true), {
    distance: 100,
})

onMounted(async () => {
    getTodayInfo()
    await loadEvents(0)
})
</script>

<template>
    <div class="events">
        <div class="events__ellipse"></div>
        <div class="events__sidepanel">
            <slot name="sidePanel"></slot>
        </div>
        <main class="events__main">
            <div class="events__main__list" ref="containerRef">
                <h2 class="events__main__list__title">
                    Сегодня — {{ today }}, {{ todayFullDate }}
                </h2>
                <EventDay
                    v-for="day in events"
                    :key="day.date"
                    :events="day.events"
                    :date="day.date"
                    @refreshEvents="loadEvents(0)"
                />
            </div>
        </main>
    </div>
</template>

<style lang="scss" scoped>
.events {
    padding: 40px;
    display: flex;
    justify-content: space-between;
    min-height: 100dvh;
    width: 100%;
    background: rgba(22, 22, 24, 0.97);

    position: relative;
    z-index: 0;

    &::before {
        content: "";
        position: absolute;
        inset: 0;
        background: rgba(255, 255, 255, 0.04);
        pointer-events: none;
        z-index: 0;
        mix-blend-mode: overlay;
    }

    &__ellipse {
        background: rgba(23, 24, 26, 1);
        position: fixed;
        bottom: 0px;
        left: 0px;
        width: 100%;
        height: 100%;
        max-height: 100dvh;
        background-image: url("/ellipse4.svg");
        background-repeat: no-repeat;
        background-position: bottom left;
        background-attachment: scroll;
        background-origin: padding-box;
        background-clip: border-box;
        background-size: contain;
        z-index: 0;
    }

    &__main {
        padding: 100px 180px;
        z-index: 1;
        width: 100%;
        display: flex;
        justify-content: center;
        align-items: center;

        &__list {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 32px;
            max-width: 1360px;
            width: 100%;
            max-height: 880px;
            overflow-y: auto;

            &::-webkit-scrollbar {
                width: 0px;
            }
            &::-webkit-scrollbar-track {
                background: transparent;
            }
            &::-webkit-scrollbar-thumb {
                background: rgba(0, 0, 0, 0.2);
                border-radius: 3px;
            }
        }
    }

    &__sidepanel {
        position: fixed;
        padding: 24px 0px;
        max-width: 368px;
        z-index: 2;
        height: calc(100vh - 80px);
        background-color: #1a1a1a;
        border-radius: 24px;
    }
}
</style>
