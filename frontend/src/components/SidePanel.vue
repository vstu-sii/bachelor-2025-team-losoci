<script setup>
import { ref, reactive, watch, computed, onMounted } from "vue"
import { onClickOutside } from "@vueuse/core"
import WarningMessage from "@/components/WarningMessage.vue"

import Chat from "@/assets/svg/Chat.svg"
import Schedule from "@/assets/svg/Schedule.svg"
import ThreeDots from "@/assets/icons/IOptions.vue"
import IGiftIcon from "@/assets/icons/IGiftIcon.vue"
import IEdit from "@/assets/icons/IEdit.vue"
import IDelete from "@/assets/icons/IDelete.vue"
import SidePanelBtn from "@/components/SidePanelBtn.vue"
import UserDefault from "@/assets/svg/UserDefault.svg"
import IProfile from "@/assets/icons/IProfile.vue"
import ILogout from "@/assets/icons/ILogout.vue"

import ChatService from "@/services/ChatService"
import UserService from "@/services/UserService"
import { useChatStore } from "@/stores/chatStore"
import { useRouter } from "vue-router"

import SearchBtn from "@/components/SearchBtn.vue"

import { useRoute } from "vue-router"

const props = defineProps({
    isProfile: {
        type: Boolean,
        default: false,
    },
})

const chats = computed(() => chatStore.chats)
const currentChat = computed(() => chatStore.currentChatId)
const chatEdditing = ref(null)
const chatDeleting = ref(null)
const userProfileOpen = ref(false)
const user = reactive({})

const chatStore = useChatStore()
const router = useRouter()
const target = ref(null)
const route = useRoute()

function createChat() {
    router.push("/")
    chatStore.setCurrentChat(null)
    chatEdditing.value = null
}

function toggleOptions(chatId) {
    chatEdditing.value = chatEdditing.value === chatId ? null : chatId
}

function registerClickOutside(el, chatId) {
    if (!el) return
    onClickOutside(el, () => {
        if (chatEdditing.value === chatId) {
            chatEdditing.value = null
        }
    })
}

const searchQuery = ref("")

const filteredChats = computed(() => {
    if (!searchQuery.value.trim()) return chats.value

    const query = searchQuery.value.toLowerCase().trim()
    return chats.value.filter((chat) =>
        chat.title?.toLowerCase().includes(query)
    )
})

async function openChat(chatId) {
    chatStore.setCurrentChat(chatId)
    try {
        const response = await ChatService.openChat(chatId)
        router.push(`/${chatId}`)
    } catch (error) {
        console.error(error)
    }
}

function toggleEdit(chat) {
    if (chat.editing) {
        saveChatTitle(chat)
    } else {
        chat.editing = true
        chatEdditing.value = chat.id
    }
}

async function logout() {
    try {
        await UserService.logout()
        router.replace("/authorization")
    } catch (error) {
        console.log(error)
    }
}

async function saveChatTitle(chat) {
    chat.editing = false
    chatEdditing.value = null
    try {
        await ChatService.updateChat({
            id: chat.id,
            title: chat.title,
            context: chat.context,
            sender_id: chat.sender_id,
        })

        const index = chatStore.chats.findIndex((c) => c.id === chat.id)
        if (index !== -1) {
            chatStore.chats[index].title = chat.title
        }
    } catch (error) {
        console.error(error)
    }
}

async function deleteChat(chatId) {
    try {
        await ChatService.deleteChat(chatId)
        chatStore.removeChat(chatId)

        if (router.currentRoute.value.params.chatId == chatId) {
            router.push("/")
        }
    } catch (error) {
        console.error(error)
    } finally {
        chatDeleting.value = null
    }
}

onClickOutside(target, () => (userProfileOpen.value = false))

onMounted(async () => {
    await chatStore.loadChats()

    try {
        const userResponse = await UserService.getUser()
        Object.assign(user, userResponse.data)
    } catch (error) {
        console.log(error)
    }
})

watch(
    () => route.params.chatId,
    (newId) => {
        chatStore.setCurrentChat(newId || null)
    },
    { immediate: true }
)
</script>

<template>
    <div :class="['sidepanel', 'sidepanel--closed']">
        <div class="sidepanel__info">
            <IGiftIcon
                class="sidepanel__info__icon"
                @click="router.push('/')"
            />
            <h2 class="sidepanel__info__title">Ai Gift Assistant</h2>
        </div>
        <section class="sidepanel__btns">
            <SidePanelBtn :image="Chat" text="Новый чат" @click="createChat" />
            <SearchBtn v-model:query="searchQuery" />
            <SidePanelBtn :image="Schedule" text="Открыть календарь" @click="router.push('/events')"/>
        </section>

        <section class="sidepanel__chats">
            <h3 class="sidepanel__chats__title">Чаты</h3>
            <ul class="sidepanel__chats__list">
                <li
                    v-for="chat in filteredChats"
                    :key="chat.id"
                    :class="[
                        'sidepanel__chats__item',
                        {
                            'sidepanel__chats__item--active':
                                chat.id === currentChat,
                        },
                    ]"
                    @click="openChat(chat.id)"
                >
                    <div class="sidepanel__chats__row">
                        <input
                            v-if="chat.editing"
                            class="sidepanel__chats__button"
                            v-model="chat.title"
                            @keyup.enter="saveChatTitle(chat)"
                            @blur="saveChatTitle(chat)"
                            autofocus
                        />
                        <button v-else class="sidepanel__chats__button">
                            {{ chat.title }}
                        </button>

                        <button
                            class="sidepanel__chats__options"
                            @click.stop="toggleOptions(chat.id)"
                        >
                            <ThreeDots />
                        </button>

                        <div
                            v-if="chat.id === chatEdditing"
                            class="sidepanel__chats__options_container"
                            :ref="(el) => registerClickOutside(el, chat.id)"
                        >
                            <button
                                class="sidepanel__chats__options_row"
                                @click="toggleEdit(chat)"
                            >
                                <IEdit />
                                <span class="sidepanel__chats__options_edit">
                                    {{
                                        chat.editing
                                            ? "Сохранить"
                                            : "Редактировать"
                                    }}
                                </span>
                            </button>

                            <button
                                class="sidepanel__chats__options_row"
                                @click="chatDeleting = chat.id"
                            >
                                <IDelete />
                                <span class="sidepanel__chats__options_delete"
                                    >Удалить</span
                                >
                            </button>
                        </div>
                    </div>
                </li>
            </ul>
        </section>
        <section class="sidepanel__user_info" ref="target" v-if="!isProfile">
            <div class="sidepanel__user_info__wrapper" v-if="userProfileOpen">
                <button
                    type="button"
                    class="sidepanel__user_info__wrapper_btn"
                    @click="router.push('/profile')"
                >
                    <IProfile class="sidepanel__user_info__wrapper_btn__icon" />
                    <span>Перейти в профиль</span>
                </button>
                <button
                    type="button"
                    class="sidepanel__user_info__wrapper_btn"
                    @click="logout"
                >
                    <ILogout class="sidepanel__user_info__wrapper_btn__icon" />
                    <span>Выйти из аккаунта</span>
                </button>
            </div>
            <div
                class="sidepanel__user_info__container"
                @click="userProfileOpen = !userProfileOpen"
            >
                <img
                    class="sidepanel__user_info__avatar"
                    :src="user.avatar ? user.avatar : UserDefault"
                    alt="avatar"
                />
                <div class="sidepanel__user_info__name">
                    <span>{{ user.username }}</span>
                    <p>{{ user.email }}</p>
                </div>
            </div>
        </section>
        <div class="sidepanel__chats__warning__container" v-if="chatDeleting">
            <WarningMessage
                class="sidepanel__chats__warning"
                message="Выбранный вами чат будет удален без возможности восстановления"
                title="Удалить чат?"
                btn1Title="Удалить"
                btn2Title="Отменить"
                @aprove-warning-message="deleteChat(chatDeleting)"
                @close-warning-message="chatDeleting = null"
            />
        </div>
    </div>
</template>

<style lang="scss" scoped>
.sidepanel {
    padding: 0px 24px;
    display: flex;
    flex-direction: column;
    gap: 32px;
    width: 368px;
    height: 100%;

    &__info {
        padding: 10px;
        display: flex;
        gap: 24px;
        align-items: center;

        &__icon {
            width: 75px;
            height: 75px;
            cursor: pointer;
        }

        &__title {
            font-size: 28px;
            font-family: var(--Montserrat);
            font-weight: 700;
            color: var(--white);
        }
    }

    &__btns {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    &__chats {
        margin-top: 32px;
        display: flex;
        flex-direction: column;
        gap: 12px;
        flex: 1;

        &__options_container {
            position: absolute;
            top: 110%;
            right: 0%;

            display: flex;
            flex-direction: column;
            gap: 12px;
            border-radius: 16px;
            padding: 8px;
            background: rgb(49, 49, 49);
            z-index: 10;
        }

        &__options_row {
            padding: 8px 12px;
            display: flex;
            gap: 12px;
            align-items: center;
            width: 240px;
            border-radius: 12px;

            &:hover {
                background: rgba(255, 255, 255, 0.2);
            }
        }

        &__options_edit {
            font-size: 16px;
            font-family: var(--Inter);
            font-weight: 400;
            color: var(--white);
        }

        &__options_delete {
            font-size: 16px;
            font-family: var(--Inter);
            font-weight: 400;
            color: var(--red);
        }

        &__title {
            font-size: 32px;
            font-family: var(--Montserrat);
            font-weight: 700;
            color: var(--white);
            text-align: center;
        }

        &__list {
            display: flex;
            flex-direction: column;
            max-height: 600px;
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

        &__item {
            flex-grow: 1;
            border-radius: 12px;
            cursor: pointer;

            &:hover .sidepanel__chats__options {
                display: inline-block;
            }

            &:hover .sidepanel__chats__button {
                padding-right: 56px;
            }

            &--active {
                background: rgba(255, 255, 255, 0.1);
                .sidepanel__chats__button {
                    color: var(--white);
                }
            }
        }

        &__row {
            align-items: center;
            display: flex;
            position: relative;
        }

        &__options {
            display: none;
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            height: 28px;
            width: 28px;
        }

        &__button {
            padding: 12px 24px;
            display: block;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            color: var(--placeholder-color);
            font-size: 20px;
            max-width: 100%;
            text-align: start;
            border-radius: 12px;
            width: 100%;

            &:hover {
                background: #676767;
                color: var(--white);
            }

            &:active {
                background: #1a1a1a;
                color: var(--white);
            }
        }

        &__warning {
            align-self: center;

            &__container {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                display: flex;
                justify-content: center;
                align-items: center;
                background: rgba(0, 0, 0, 0.5);
                z-index: 9999;
                backdrop-filter: blur(1px);
            }
        }
    }

    &__user_info {
        margin: 0px -8px;
        position: relative;

        &__container {
            width: 100%;
            padding: 6px 8px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-radius: 24px;
            cursor: pointer;

            &:hover {
                background-color: rgb(49, 49, 49);
            }
        }

        &__avatar {
            width: 76px;
            height: 76px;
            border-radius: 50%;
        }

        &__name {
            font-size: 24px;
            font-family: var(--Montserrat);
            font-weight: 700;
            color: var(--white);

            & p {
                font-size: 16px;
                color: var(--placeholder-color);
            }
        }

        &__wrapper {
            padding: 8px;
            position: absolute;
            bottom: 110%;
            width: 100%;
            left: 0px;
            display: flex;
            flex-direction: column;
            background-color: rgb(36, 36, 36);
            border-radius: 16px;

            &_btn {
                padding: 12px 24px;
                font-size: 18px;
                font-family: var(--Inter);
                color: var(--text-color);
                display: flex;
                align-items: center;
                gap: 12px;
                border-radius: 12px;

                &:hover {
                    background-color: rgb(49, 49, 49);
                }

                &__icon {
                    width: 40px;
                    height: 40px;
                }
            }
        }
    }
}
</style>
