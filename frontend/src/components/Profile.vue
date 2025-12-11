<script setup>
import { ref, reactive, computed, onMounted } from "vue"

import { UserService } from "@/services"
import { userUpdateSchema } from "@/validation/updateUserSchema"
import { validate } from "@/middlewares/validate"
import { useRouter } from "vue-router"

import "dropzone-vue/dist/dropzone-vue.common.css"

import WarningMessage from "@/components/WarningMessage.vue"
import InputWithTitle from "@/components/InputWithTitle.vue"
import UserDefault from "@/assets/svg/UserDefault.svg"
import IDelete from "@/assets/icons/IDelete.vue"

const genderTypes = ["мужской", "женский"]

const errors = {
    400: "Пользовытель уже существует",
    422: "Все поля обязательны для заполнения",
    500: "Внутренняя ошибка сервера",
}

const router = useRouter()

const errorExist = ref({
    error: false,
    errorMessage: "",
})

const isWide = ref(false)
const isEditing = ref(false)
const isDeleting = ref(false)

const updatingPhoto = ref(null)

const user = reactive({
    username: "",
    name: "",
    surname: "",
    email: "",
    birthdate: "",
    gender: "",
    telegram_link: "",
    telegram_init_id: "",
    telegram_username: "",
    avatar: "",
    description: "",
})

const userCopy = reactive({
    username: "",
    name: "",
    surname: "",
    email: "",
    birthdate: "",
    gender: "",
    telegram_link: "",
    telegram_init_id: "",
    telegram_username: "",
    avatar: "",
    description: "",
})

function cancelUpdate() {
    isEditing.value = false
    Object.assign(user, userCopy)
    if (user.telegram_username)
        user.telegram_link = "@" + user.telegram_username
}

function editUser() {
    isEditing.value = true
    if (user.telegram_username)
        user.telegram_link = "@" + user.telegram_username
}

async function updateUser() {
    errorExist.value = { error: false, errorMessage: "" }

    if (user.telegram_username)
        user.telegram_link = "@" + user.telegram_username

    try {
        const { valid, errors: validationErrors } = await validate(
            userUpdateSchema,
            user
        )

        if (!valid) {
            errorExist.value = {
                error: true,
                errorMessage: Object.values(validationErrors)[0],
            }
            return
        }

        const userResponse = await UserService.updateUser(user)

        if (userResponse.data.deepLink) {
            window.location.href = userResponse.data.deepLink
        }

        Object.assign(userCopy, userResponse.data.user)
        Object.assign(user, userResponse.data.user)

        if (user.birthdate) {
            const date = new Date(user.birthdate)
            const year = date.getFullYear()
            const month = String(date.getMonth() + 1).padStart(2, "0")
            const day = String(date.getDate()).padStart(2, "0")
            user.birthdate = `${year}-${month}-${day}`
            userCopy.birthdate = user.birthdate
        }

        if (updatingPhoto.value) {
            const formData = new FormData()
            formData.append("avatar", updatingPhoto.value)

            try {
                const photoResponse = await UserService.updatePhoto(formData)
                user.avatar = photoResponse.avatarUrl
                userCopy.avatar = photoResponse.avatarUrl
                currentAvatar.value = photoResponse.avatarUrl
                updatingPhoto.value = null
            } catch (error) {
                console.error("Ошибка при обновлении фото:", error)
            }
        }

        isEditing.value = false
    } catch (error) {
        if (error.response && errors[error.response.status]) {
            errorExist.value = {
                error: true,
                errorMessage: errors[error.response.status],
            }
        } else {
            errorExist.value = {
                error: true,
                errorMessage: "Внутренняя ошибка сервера",
            }
        }
    }
}

async function deleteAccount() {
    try {
        await UserService.deleteUser()
        router.replace("/authorization")
    } catch (error) {}
}

async function onAvatarChange(event) {
    const file = event.target.files[0]
    if (!file) return

    updatingPhoto.value = file
    user.avatar = URL.createObjectURL(file)
}

const currentAvatar = computed(() => {
    return user.avatar ? user.avatar : UserDefault
})

onMounted(async () => {
    try {
        const userResponse = await UserService.getUser()
        Object.assign(user, userResponse.data)
        Object.assign(userCopy, userResponse.data)

        if (user.telegram_username)
            user.telegram_link = "@" + user.telegram_username
        else user.telegram_link = ""

        if (user.birthdate) {
            const date = new Date(user.birthdate)
            const year = date.getFullYear()
            const month = String(date.getMonth() + 1).padStart(2, "0")
            const day = String(date.getDate()).padStart(2, "0")
            user.birthdate = `${year}-${month}-${day}`
            userCopy.birthdate = user.birthdate
        }
    } catch (error) {
        console.log(error)
    }
})
</script>

<template>
    <div :class="['profile', { 'profile--wide': isWide }]">
        <div class="profile__top_container">
            <div class="profile__top_container__btns">
                <button
                    type="button"
                    class="profile__top_container__btns__logout"
                    @click="isDeleting = true"
                >
                    <IDelete />
                </button>
                <WarningMessage
                    class="profile__top_container__btns__warning"
                    title="Удаление аккаунта"
                    message="Вы уверены, что хотите удалить аккаунт?"
                    :btn1Title="'Да'"
                    :btn2Title="'Нет'"
                    v-if="isDeleting"
                    @aprove-warning-message="deleteAccount"
                    @close-warning-message="isDeleting = false"
                />
            </div>
            <div class="profile__top_container__avatar">
                <img
                    class="profile__top_container__avatar__img"
                    :src="currentAvatar"
                />
                <input
                    v-if="isEditing"
                    id="avatar"
                    type="file"
                    accept=".jpg,.png,.jpeg"
                    class="profile__top_container__avatar__input"
                    @change="onAvatarChange"
                />
            </div>
            <div class="profile__top_container__short_info">
                <h2 class="profile__top_container__short_info__username">
                    {{ user.username }}
                </h2>
                <h3 class="profile__top_container__short_info__email">
                    {{ user.email }}
                </h3>
            </div>
        </div>
        <div class="profile__inputs">
            <div class="profile__inputs__wrapper">
                <InputWithTitle
                    title="Имя"
                    placeholder="Имя"
                    v-model="user.name"
                    :disabled="!isEditing"
                />
                <InputWithTitle
                    title="Фамилия"
                    placeholder="Фамилия"
                    v-model="user.surname"
                    :disabled="!isEditing"
                />
                <InputWithTitle
                    title="Почта"
                    placeholder="Почта"
                    v-model="user.email"
                    :disabled="true"
                />
                <InputWithTitle
                    title="Дата рождения"
                    placeholder="Дата рождения"
                    v-model="user.birthdate"
                    :disabled="!isEditing"
                    type="date"
                />
                <div class="profile__inputs__select">
                    <span class="profile__inputs__select__title">Пол</span>
                    <BaseSelect
                        :options="genderTypes"
                        v-model="user.gender"
                        :disabled="!isEditing"
                    />
                </div>

                <InputWithTitle
                    title="Телеграмм"
                    placeholder="Телеграмм"
                    v-model="user.telegram_link"
                    :disabled="!isEditing"
                />
            </div>
            <span class="profile__inputs__error" v-if="errorExist.error">{{
                errorExist.errorMessage
            }}</span>
            <InputWithTitle
                title="Обо мне"
                placeholder="Напишите о своих увлечениях"
                v-model="user.description"
                :disabled="!isEditing"
            />
        </div>
        <div class="profile__buttons" v-if="isEditing">
            <BaseButton text="Сохранить" @click="updateUser" />
            <BaseButton text="Отменить" @click="cancelUpdate" />
        </div>
        <div class="profile__buttons--short" v-else>
            <BaseButton text="Изменить" @click="editUser" />
        </div>
    </div>
</template>

<style lang="scss" scoped>
.profile {
    padding: 100px 180px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 64px;
    max-width: 1424px;

    &__top_container {
        position: relative;
        width: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 20px;

        &__btns {
            display: flex;
            gap: 12px;
            position: absolute;
            top: 0px;
            right: 0px;

            &__warning {
                position: absolute;
                top: 60px;
                right: 0px;
                width: 440px;
            }
        }

        &__avatar {
            position: relative;
            width: 234px;
            height: 234px;
            border-radius: 50%;

            &__btn {
                position: absolute;
                top: 0;
                right: 0;
                width: 48px;
                height: 48px;
                background-color: var(--white);
                border-radius: 50%;
                box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.25);
            }

            &__img {
                width: 234px;
                height: 234px;
                border-radius: 50%;
                user-select: none;
            }

            &__input {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                width: 100%;
                height: 100%;
                opacity: 0;
                border-radius: 50%;
                cursor: pointer;
            }
        }

        &__short_info {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 4px;

            &__username {
                font-size: 52px;
                font-weight: 700;
                font-family: var(--Montserrat);
                line-height: 1.2;
                color: var(--white);
            }

            &__email {
                font-size: 24px;
                font-weight: 400;
                font-family: var(--Inter);
                line-height: 1.2;
                color: var(--placeholder-color);
            }
        }
    }

    &__inputs {
        width: 100%;
        display: flex;
        flex-direction: column;
        gap: 32px;

        &__wrapper {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 32px;
            flex-wrap: wrap;
        }

        &__select {
            display: flex;
            flex-direction: column;
            gap: 12px;

            &__title {
                margin: 0px 16px;
                font-size: 24px;
                font-family: var(--Inter);
                line-height: 1.2;
                color: var(--placeholder-color);
            }
        }

        &__error {
            text-align: center;
            font-size: 16px;
            font-weight: 600;
            font-family: var(--Inter);
            line-height: 1.33;
            color: var(--red);
        }
    }

    &__buttons {
        width: 100%;
        display: flex;
        justify-content: space-between;
        gap: 32px;

        &--short {
            max-width: 352px;
            width: 100%;
            display: flex;
            justify-content: center;
        }
    }
}
</style>
