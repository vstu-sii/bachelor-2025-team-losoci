<script setup>
import { ref, watch } from "vue"
import UserService from "@/services/UserService"
import { EventService } from "@/services/EventService"
import BaseInput from "./base/BaseInput.vue"

const props = defineProps({
    events: {
        type: Array,
        required: true,
    },
    date: {
        type: String,
        required: true,
    },
})

const emit = defineEmits(["refreshEvents"])

const eventData = ref({
    id: null,
    title: "",
    description: "",
    recipient_id: null,
    recipient: "",
    importance_id: null,
    completed: false,
    date: props.date,
})

const isEditing = ref(false)
const isCreating = ref(false)
const searchResults = ref([])
const isSearching = ref(false)
const isLoading = ref(false)

async function searchUsers(query) {
    if (!query.trim()) {
        searchResults.value = []
        return
    }
    isSearching.value = true
    try {
        const { data } = await UserService.searchUser({
            username: query,
            email: query,
        })
        searchResults.value = data.slice(0, 5)
    } catch (err) {
        console.error("Search error:", err)
        searchResults.value = []
    } finally {
        isSearching.value = false
    }
}

function formatDateForInput(dateString) {
    const date = new Date(dateString)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
}

function selectUser(user) {
    eventData.value.recipient = user.username || user.name
    eventData.value.recipient_id = user.id
    searchResults.value = []
}

watch(
    () => eventData.value.recipient,
    (val) => {
        if (val && val.length > 1) searchUsers(val)
        else searchResults.value = []
    }
)

function openCreateForm() {
    resetEventData()
    eventData.value.date = formatDateForInput(props.date)
    isCreating.value = true
    isEditing.value = true
}

function openEditForm(event) {
    console.log(event)
    eventData.value = {
        ...event,
        recipient: event.userName || "",
        date: formatDateForInput(event.date),
    }
    isCreating.value = false
    isEditing.value = true
}

function cancelEditing() {
    isEditing.value = false
    resetEventData()
}

function resetEventData() {
    eventData.value = {
        id: null,
        title: "",
        description: "",
        recipient: "",
        recipient_id: null,
        importance_id: null,
        completed: false,
        date: props.date,
    }
}

async function createEvent() {
    try {
        isLoading.value = true
        const payload = {
            title: eventData.value.title,
            description: eventData.value.description,
            date: eventData.value.date,
            recipient_id: eventData.value.recipient_id || null,
        }

        await EventService.createEvent(payload)
        emit("refreshEvents")
        cancelEditing()
    } catch (err) {
        console.error("Ошибка при создании события:", err)
    } finally {
        isLoading.value = false
    }
}

async function updateEvent() {
    try {
        isLoading.value = true
        const payload = {
            id: eventData.value.id,
            title: eventData.value.title,
            description: eventData.value.description,
            date: eventData.value.date,
            recipient_id: eventData.value.recipient_id || null,
        }

        await EventService.updateEvent(payload)
        emit("refreshEvents")
        cancelEditing()
    } catch (err) {
        console.error("Ошибка при обновлении события:", err)
    } finally {
        isLoading.value = false
    }
}
</script>

<template>
    <div class="event_day">
        <div class="event_day__header">
            <span class="event_day__date" @dblclick="openCreateForm">{{
                date.split("T")[0]
            }}</span>
        </div>
        <div class="event_day__list" v-if="events[0].id || isEditing">
            <div class="event_day__list__edit" v-if="isEditing">
                <BaseInput
                    v-model="eventData.title"
                    placeholder="Название"
                    class="event_day__list__edit__input"
                />
                <BaseInput
                    v-model="eventData.description"
                    placeholder="Описание"
                    class="event_day__list__edit__input"
                />

                <div class="recipient-wrapper">
                    <BaseInput
                        id="recipientInput"
                        placeholder="Получатель"
                        v-model="eventData.recipient"
                        @focus="searchResults = []"
                    />

                    <transition name="fade">
                        <ul
                            v-if="searchResults.length > 0"
                            class="recipient-dropdown"
                        >
                            <li
                                v-for="user in searchResults"
                                :key="user.id"
                                @click="selectUser(user)"
                                class="recipient-dropdown__item"
                            >
                                <img
                                    v-if="user.avatar"
                                    :src="user.avatar"
                                    class="recipient-dropdown__avatar"
                                />
                                <div class="recipient-dropdown__info">
                                    <div class="name">
                                        {{ user.username || user.name }}
                                    </div>
                                    <div class="email">{{ user.email }}</div>
                                </div>
                            </li>
                        </ul>
                    </transition>

                    <div v-if="isSearching" class="recipient-loading">
                        <div class="spinner"></div>
                    </div>
                </div>

                <div class="event_day__actions">
                    <button
                        v-if="isCreating"
                        class="btn btn--create"
                        @click="createEvent"
                        :disabled="isLoading"
                    >
                        {{ isLoading ? "Создание..." : "Создать" }}
                    </button>
                    <button
                        v-else
                        class="btn btn--edit"
                        @click="updateEvent"
                        :disabled="isLoading"
                    >
                        {{ isLoading ? "Сохранение..." : "Редактировать" }}
                    </button>
                    <button class="btn btn--cancel" @click="cancelEditing">
                        Отмена
                    </button>
                </div>
            </div>

            <div
                class="event_day__list__item"
                v-for="event in events"
                :key="event.id"
                @dblclick="openEditForm(event)"
            >
                <span class="event_day__list__item__title">{{
                    event.title
                }}</span>
            </div>
        </div>
        <div class="event_day__delimiter"></div>
    </div>
</template>

<style scoped lang="scss">
.event_day {
    border-radius: 10px;
    padding: 10px;
    margin-bottom: 16px;
    transition: 0.3s;
    width: 100%;
    max-width: 800px;
    display: flex;
    flex-direction: column;
    gap: 20px;

    &__delimiter {
        width: 100%;
        height: 2px;
        background: var(--placeholder-color);
    }

    &__header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 2rem;
        color: var(--white);
        font-weight: 700;
        font-family: var(--Montserrat);
    }

    &__date {
        user-select: none;
        cursor: pointer;
        text-decoration: underline;
    }

    &__list__edit {
        margin: 10px 10px 20px 10px;
        display: flex;
        flex-direction: column;
        gap: 8px;
        background-color: rgb(59, 59, 59);
        padding: 12px;
        border-radius: 24px;
    }

    &__actions {
        display: flex;
        justify-content: flex-end;
        gap: 16px;
        margin: 10px 0px 0px 0px;

        .btn {
            padding: 12px 24px;
            border-radius: 12px;
            cursor: pointer;
            border: none;
            font-size: 20px;
            font-family: var(--Inter);

            &--create {
                background: linear-gradient(135deg, #a855f7, #7c3aed);
                color: var(--white);

                &:hover {
                    background: linear-gradient(135deg, #7c3aed, #a855f7);
                }
            }

            &--edit {
                background: linear-gradient(135deg, #a855f7, #7c3aed);
                color: var(--white);

                &:hover {
                    background: linear-gradient(135deg, #7c3aed, #a855f7);
                }
            }

            &--cancel {
                background: var(--red);
                color: var(--white);

                &:hover {
                    background: rgb(216, 10, 10);
                }
            }
        }
    }

    &__list__item {
        margin-top: 6px;
        padding: 6px;
        border-radius: 6px;
        background: var(--purple);
        cursor: pointer;
        transition: 0.2s;
        font-size: 20px;
        font-family: var(--Inter);
        font-weight: 600;
        user-select: none;
        color: var(--white);

        &:hover {
            background: var(--grey);
        }
    }
}

.recipient-wrapper {
    position: relative;
}

.recipient-dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border: 1px solid #ddd;
    border-radius: 6px;
    max-height: 200px;
    overflow-y: auto;
    z-index: 10;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);

    &__item {
        display: flex;
        align-items: center;
        padding: 8px 10px;
        cursor: pointer;
        transition: background 0.2s;

        &:hover {
            background: #f3f3f3;
        }
    }

    &__avatar {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        margin-right: 8px;
    }

    &__info {
        display: flex;
        flex-direction: column;
        font-size: 14px;

        .name {
            font-weight: 600;
        }

        .email {
            font-size: 12px;
            color: #777;
        }
    }
}

.recipient-loading {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
}

.spinner {
    width: 14px;
    height: 14px;
    border: 2px solid #ccc;
    border-top-color: #333;
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}
</style>
