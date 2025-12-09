<script setup>
import { ref, computed, reactive, onMounted, watch, nextTick } from "vue"
import { useRoute } from "vue-router"
import { onClickOutside, useClipboard } from "@vueuse/core"

import { toast } from "vue3-toastify"
import "vue3-toastify/dist/index.css"

import MessageService from "@/services/MessageService"
import ChatService from "@/services/ChatService"
import UserService from "@/services/UserService"
import { parseMarkdown } from "@/utils/markdown"
import { buildPromptFromForm } from "@/utils/messageUtils"
import { useChatStore } from "@/stores/chatStore"

import SendMessage from "@/assets/svg/SendMessage.svg"
import IForm from "@/assets/svg/IForm.svg"
import ICopy from "@/assets/icons/ICopy.vue"
import ILike from "@/assets/icons/ILike.vue"
import IDislike from "@/assets/icons/IDislike.vue"

const route = useRoute()
const chatId = ref(route.params.chatId)
const chatData = ref({})
const messages = ref([])

const promptValue = ref("")
const botAnser = ref("")

const typingInterval = ref(null)
const messagesContainer = ref(null)

const isFormOpen = ref(false)
const recipient = ref({})

const clipBoard = useClipboard()
const chatStore = useChatStore()

const formData = reactive({
    recipient: "",
    description: "",
    event: "",
})

const searchResults = ref([])
const isSearching = ref(false)
const searchTimeout = ref(null)
const target = ref(null)

function debouncedSearch(query) {
    clearTimeout(searchTimeout.value)
    searchTimeout.value = setTimeout(() => searchUsers(query), 300)
}

function selectUser(user) {
    formData.recipient = user.username || user.name || user.email
    recipient.value = { ...user }
    searchResults.value = []
}

function scrollToBottom(smooth = true) {
    nextTick(() => {
        const el = messagesContainer.value
        if (!el) return
        requestAnimationFrame(() => {
            el.scrollTo({
                top: el.scrollHeight,
                behavior: smooth ? "smooth" : "auto",
            })
        })
    })
}

const recipientImage = computed(() =>
    recipient.value.avatar ? recipient.value.avatar : IForm
)

function toggleForm() {
    if (recipient.value.avatar) return
    isFormOpen.value = !isFormOpen.value
}

function copyToClipboard(text) {
    clipBoard.copy(text)
    toast.success("Текст скопирован", {
        theme: "dark",
        type: "success",
        dangerouslyHTMLString: true,
        autoClose: 2000,
    })
}

async function loadRecipient(recipientId) {
    if (!recipientId) {
        recipient.value = {}
        return
    }
    try {
        const res = await UserService.getUser(recipientId)
        recipient.value = { ...res.data }
    } catch (err) {
        console.error("Ошибка загрузки получателя:", err)
        recipient.value = {}
    }
}

async function ensureChatExists(initialPrompt = "", recipientId = null) {
    if (chatId.value) return chatId.value
    console.log(recipientId)
    console.log(recipient.value)
    const payload = {
        title:
            initialPrompt.substring(0, 50) +
            (initialPrompt.length > 50 ? "..." : ""),
        context: initialPrompt,
        ...(recipientId && { recipient_id: recipientId }),
    }

    try {
        const { data } = await ChatService.createChat(payload)
        const newChatId = data.id

        chatId.value = newChatId
        chatStore.addChat({
            id: newChatId,
            title: payload.title,
            context: payload.context,
            recipient_id: recipientId || null,
        })
        chatStore.setCurrentChat(newChatId)

        const fullChat = await ChatService.openChat(newChatId)
        chatData.value = { ...fullChat.data }

        if (recipientId) await loadRecipient(recipientId)

        messages.value = []
        return newChatId
    } catch (err) {
        toast.error("Не удалось создать чат")
        throw err
    }
}

async function sendPrompt() {
    if (!promptValue.value?.trim()) return

    if (typingInterval.value !== null) {
        clearTimeout(typingInterval.value)
        typingInterval.value = null
    }

    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 60_000)

    try {
        let currentChatId = chatId.value

        if (!currentChatId) {
            currentChatId = await ensureChatExists(promptValue.value)
        }

        const userMessage = promptValue.value
        const messageRequest = {
            chatId: currentChatId,
            message: userMessage,
            sender_id: chatData.value.sender_id,
            recipient_id: chatData.value.recipient_id ?? null,
        }

        messages.value.push({
            id: Date.now(),
            text: userMessage,
            role: "user",
        })

        promptValue.value = ""
        botAnser.value = ""
        scrollToBottom()

        const result = await MessageService.sendMessage(messageRequest)
        if (!result.success || !result.answer) {
            throw new Error(result.error || "No answer from AI")
        }

        const fullAnswer = result.answer
        let index = 0
        const chunkSize = 2
        const delay = 25

        const assistantMsg = {
            id: Date.now() + 1,
            text: "",
            role: "assistant",
            isPending: true,
        }
        messages.value.push(assistantMsg)
        scrollToBottom()

        const typeNextChunk = () => {
            if (index < fullAnswer.length && !controller.signal.aborted) {
                const nextChunk = fullAnswer.slice(index, index + chunkSize)
                assistantMsg.text += nextChunk
                index += chunkSize
                scrollToBottom()
                typingInterval.value = setTimeout(typeNextChunk, delay)
            } else {
                assistantMsg.text = fullAnswer
                assistantMsg.isPending = false
                scrollToBottom()
            }
        }
        typeNextChunk()
    } catch (err) {
        if (err.name !== "AbortError") {
            console.error("Error:", err)
            messages.value.push({
                id: Date.now(),
                text: `[ERROR: ${err.message || "AI недоступен"}]`,
                role: "assistant",
            })
        }
    } finally {
        clearTimeout(timeout)
    }
}

async function sendFormAsPrompt() {
    const prompt = buildPromptFromForm(recipient.value, formData)
    await nextTick()

    if (!prompt || !recipient.value.id) {
        toast.error(!prompt ? "Заполните поля" : "Выберите получателя")
        return
    }

    await ensureChatExists(prompt, recipient.value.id)

    promptValue.value = prompt
    isFormOpen.value = false
    formData.event = ""
    formData.description = ""

    await sendPrompt()
}

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

async function loadChatData(chatIdParam) {
    try {
        const { data: msgsData } = await MessageService.getMessages(chatIdParam)
        const msgs = msgsData.messages ?? msgsData ?? []
        messages.value = Array.isArray(msgs) ? msgs : []

        const { data: chatResp } = await ChatService.openChat(chatIdParam)
        chatData.value = { ...chatResp }

        if (chatData.value.recipient_id) {
            await loadRecipient(chatData.value.recipient_id)
        }

        messages.value.forEach((m) => (m.isPending = false))
        nextTick(() => scrollToBottom())
    } catch (error) {
        console.error("Ошибка загрузки чата:", error)
        messages.value = []
    }
}

async function addRecipientToChat() {
    if (!chatId.value || !recipient.value.id) return
    try {
        const { data } = await ChatService.addRecipient(chatId.value, {
            recipient_id: recipient.value.id,
        })
        chatData.value = { ...data }
        if (chatData.value.recipient_id) {
            await loadRecipient(chatData.value.recipient_id)
        }
        isFormOpen.value = false
    } catch (e) {
        toast.error("Не удалось обновить получателя")
    }
}

function clearChatState() {
    messages.value = []
    chatData.value = {}
    recipient.value = {}
    formData.recipient = ""
    formData.event = ""
    formData.description = ""
    isFormOpen.value = false
    searchResults.value = []
    isSearching.value = false
    promptValue.value = ""
}

onClickOutside(target, () => (isFormOpen.value = false))

onMounted(async () => {
    clearChatState()
    await chatStore.loadChats()
    if (chatId.value) await loadChatData(chatId.value)
})

watch(
    () => route.params.chatId,
    async (newChatId) => {
        if (!newChatId) {
            chatId.value = null
            clearChatState()
            return
        }
        if (newChatId === chatId.value) return
        clearChatState()
        chatId.value = newChatId
        await loadChatData(newChatId)
    },
    { immediate: true }
)

watch(
    () => formData.recipient,
    (newVal) => debouncedSearch(newVal)
)
</script>

<template>
    <div :class="['chat', { 'chat--start': !chatId }]">
        <div class="chat__wrapper">
            <div class="chat__messages__scroll" ref="messagesContainer">
                <div class="chat__messages">
                    <div
                        class="chat__messages__container"
                        v-for="message in messages"
                        :key="message.id"
                    >
                        <div
                            :class="[
                                `chat__messages__text`,
                                message.role === 'user'
                                    ? 'chat__messages__text--user'
                                    : 'chat__messages__text--assistant',
                            ]"
                            v-html="parseMarkdown(message.text)"
                        ></div>
                        <div
                            class="chat__messages__container__buttons"
                            v-if="
                                message.role === 'assistant' &&
                                !message.isPending
                            "
                        >
                            <ILike
                                class="chat__messages__container__buttons__btn"
                            />
                            <IDislike
                                class="chat__messages__container__buttons__btn"
                            />
                            <ICopy
                                class="chat__messages__container__buttons__btn"
                                @click="copyToClipboard(message.text)"
                            />
                        </div>
                    </div>
                </div>
            </div>
            <div
                :class="[
                    'chat__input__container',
                    { 'chat__input__container--start': !chatId },
                ]"
            >
                <div class="chat__fade"></div>
                <BaseInput
                    v-model="promptValue"
                    :image="SendMessage"
                    :image2="recipientImage"
                    id="sendPrompt"
                    placeholder="Введите запрос"
                    @image-click="sendPrompt"
                    @image2-click="toggleForm"
                    @keydown.enter="sendPrompt"
                    class="chat__input"
                />
                <div
                    class="chat__user__form"
                    v-if="!chatData.recipient_id && isFormOpen"
                    ref="target"
                >
                    <div class="chat__user__form__inputs">
                        <div class="chat__user__form__recipient">
                            <img
                                v-if="recipient.avatar"
                                class="chat__user__form__recipient__img"
                                :src="recipient.avatar"
                                alt="avatar"
                            />
                            <div
                                class="chat__user__form__recipient__input-wrapper"
                            >
                                <BaseInput
                                    id="recipientInput"
                                    placeholder="Получатель"
                                    v-model="formData.recipient"
                                    @focus="searchResults = []"
                                />

                                <transition name="fade">
                                    <ul
                                        v-if="searchResults.length > 0"
                                        class="chat__user__form__recipient__dropdown"
                                    >
                                        <li
                                            v-for="user in searchResults"
                                            :key="user.id"
                                            @click="selectUser(user)"
                                            class="chat__user__form__recipient__dropdown__item"
                                        >
                                            <img
                                                v-if="user.avatar"
                                                :src="user.avatar"
                                                class="chat__user__form__recipient__dropdown__avatar"
                                            />
                                            <div
                                                class="chat__user__form__recipient__dropdown__info"
                                            >
                                                <div class="name">
                                                    {{
                                                        user.username ||
                                                        user.name
                                                    }}
                                                </div>
                                                <div class="email">
                                                    {{ user.email }}
                                                </div>
                                            </div>
                                        </li>
                                    </ul>
                                </transition>
                                <button
                                    class="chat__user__form__recipient__btn"
                                ></button>
                                <div
                                    v-if="isSearching"
                                    class="chat__user__form__recipient__loading"
                                >
                                    <div class="spinner"></div>
                                </div>
                            </div>
                        </div>
                        <BaseInput
                            id="eventInput"
                            placeholder="Событие"
                            v-model="formData.event"
                        />
                        <BaseInput
                            id="descriptionInput"
                            placeholder="Описание"
                            v-model="formData.description"
                        />

                        <button
                            @click="sendFormAsPrompt"
                            class="chat__user__form__submit"
                            :disabled="
                                !recipient.id ||
                                (!formData.event && !formData.description)
                            "
                        >
                            Отправить как запрос
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.chat {
    padding: 40px 16px;
    display: flex;
    width: 100%;
    height: 100%;
    flex-direction: column;
    align-items: center;
    justify-content: end;

    &--start {
        justify-content: center;
    }

    &__wrapper {
        display: flex;
        flex-direction: column;
        width: 100%;
        height: 100%;
        position: relative;
    }

    &__messages {
        width: 100%;
        flex: 1;
        padding: 0 8px 120px 8px;
        display: flex;
        flex-direction: column;
        justify-content: end;
        gap: 48px;
        max-width: 1072px;

        &__container {
            display: flex;
            flex-direction: column;
            gap: 20px;

            &__buttons {
                margin-left: 24px;

                &__btn {
                    cursor: pointer;
                }
            }
        }

        &__scroll {
            width: 100%;
            display: flex;
            align-items: center;
            flex-direction: column;
            max-height: calc(100vh - 160px);
            height: 100%;
            overflow-y: auto;
            overflow-x: hidden;
            scroll-behavior: smooth;

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

    &__messages__text {
        word-wrap: break-word;
        font-size: 24px;
        line-height: 1.4;
        align-self: flex-start;
        color: var(--white);

        &--user {
            max-width: 60%;
            padding: 24px;
            align-self: flex-end;
            color: var(--white);
            border-radius: 20px;
            border: 1px solid var(--white);
        }

        &--assistant {
            padding: 0px 24px;
            align-self: flex-start;
            color: var(--white);

            p {
                margin: 12px 0;
            }

            strong,
            b {
                color: #ffffff;
                font-weight: 700;
                text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
            }

            em,
            i {
                color: #d4b8ff;
                font-style: italic;
            }

            ul,
            ol {
                margin: 14px 0;
                padding-left: 20px;
            }

            li {
                margin: 8px 0;
                position: relative;
                padding-left: 8px;

                &::marker {
                    color: #a855f7;
                    font-weight: bold;
                }
            }

            ol {
                counter-reset: item;

                li {
                    counter-increment: item;
                    list-style: none;
                    padding-left: 0;

                    &::before {
                        content: counter(item) ".";
                        color: #a855f7;
                        font-weight: bold;
                        margin-right: 8px;
                        font-size: 1.1em;
                    }
                }
            }

            ul {
                li::before {
                    content: "•";
                    color: #a855f7;
                    font-weight: bold;
                    position: absolute;
                    left: 0;
                    font-size: 1.2em;
                    top: 0;
                }
            }

            code {
                background: rgba(0, 0, 0, 0.4);
                color: #a0d8ff;
                padding: 2px 6px;
                border-radius: 4px;
                font-family: "JetBrains Mono", monospace;
                font-size: 0.88em;
            }

            pre {
                background: rgba(0, 0, 0, 0.5);
                padding: 14px;
                border-radius: 10px;
                overflow-x: auto;
                margin: 16px 0;
                border: 1px solid rgba(180, 120, 240, 0.2);

                code {
                    background: none;
                    padding: 0;
                    color: #a0d8ff;
                    font-size: 0.9em;
                }
            }

            blockquote {
                border-left: 4px solid #a855f7;
                padding-left: 16px;
                margin: 16px 0;
                font-style: italic;
                color: #c8a8ff;
                background: rgba(168, 85, 247, 0.1);
                border-radius: 0 8px 8px 0;
            }

            a {
                color: #c684ff;
                text-decoration: underline;
                text-underline-offset: 2px;

                &:hover {
                    color: #e6d9ff;
                }
            }

            * {
                transition: all 0.2s ease;
            }
        }
    }

    &__user__form {
        padding: 24px;
        position: absolute;
        bottom: calc(100% + 12px);
        right: -10%;
        max-width: 540px;
        width: 100%;
        background: rgba(26, 26, 26, 0.85);
        backdrop-filter: blur(12px);
        border-radius: 16px;
        box-shadow: 0 -6px 20px rgba(0, 0, 0, 0.2);
        z-index: 20;
        transform-origin: bottom;

        .chat__input__container--start &,
        .chat__input__container:not(.chat__input__container--start) & {
            opacity: 1;
            transform: translateY(0);
            pointer-events: auto;
        }

        &__inputs {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        &__submit {
            margin-top: 12px;
            padding: 12px 20px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.2s;
            align-self: flex-end;

            &:hover:not(:disabled) {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(168, 85, 247, 0.4);
            }

            &:disabled {
                opacity: 0.5;
                cursor: not-allowed;
                transform: none;
            }
        }
        &__recipient {
            position: relative;

            &__input-wrapper {
                position: relative;
                flex: 1;
            }

            &__dropdown {
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background: rgba(26, 26, 26, 0.95);
                backdrop-filter: blur(12px);
                border-radius: 12px;
                margin-top: 6px;
                list-style: none;
                padding: 8px 0;
                max-height: 240px;
                overflow-y: auto;
                z-index: 30;
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
                border: 1px solid rgba(255, 255, 255, 0.1);

                &__item {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    padding: 10px 14px;
                    cursor: pointer;
                    transition: background 0.2s;

                    &:hover {
                        background: rgba(168, 85, 247, 0.2);
                    }
                }

                &__avatar {
                    width: 32px;
                    height: 32px;
                    border-radius: 50%;
                }

                &__info {
                    flex: 1;
                    .name {
                        font-weight: 600;
                        color: #fff;
                        font-size: 15px;
                    }
                    .email {
                        font-size: 13px;
                        color: rgba(255, 255, 255, 0.6);
                    }
                }
            }

            &__loading {
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                padding: 12px;
                text-align: center;
                .spinner {
                    width: 16px;
                    height: 16px;
                    border: 2px solid transparent;
                    border-top-color: #a855f7;
                    border-radius: 50%;
                    animation: spin 0.8s linear infinite;
                    display: inline-block;
                }
            }
        }
    }

    &__input__container--start {
        .chat__user__form {
            bottom: calc(100% + 16px);
            left: 70%;
            right: auto;
            transform: translateX(-50%);
            width: 100%;
            max-width: 600px;
        }
    }

    &__input__container {
        position: fixed;
        bottom: 40px;
        left: 50%;
        transform: translateX(-50%);
        width: 100%;
        max-width: 1072px;
        background: rgba(26, 26, 26, 0.6);
        backdrop-filter: blur(10px);
        z-index: 10;
        border-radius: 24px;

        &--start {
            background: none;
            bottom: 50%;
        }
    }

    &__fade {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        height: 80px;
        backdrop-filter: blur(10px);
        pointer-events: none;
        z-index: 5;
    }

    // === Input ===
    &__input {
        width: 100%;
        border-radius: 24px;
        box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
    }

    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }

    .fade-enter-active,
    .fade-leave-active {
        transition: opacity 0.2s, transform 0.2s;
    }
    .fade-enter-from,
    .fade-leave-to {
        opacity: 0;
        transform: translateY(-4px);
    }
}
</style>
