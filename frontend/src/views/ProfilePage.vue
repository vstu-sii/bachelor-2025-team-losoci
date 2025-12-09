<script setup>
import Profile from "@/components/Profile.vue"
import ProfileLayout from "@/layouts/ProfileLayout.vue"
import SidePanel from "@/components/SidePanel.vue"
</script>

<template>
    <ProfileLayout>
        <template #sidePanel>
            <SidePanel isProfile />
        </template>
        <Profile />
    </ProfileLayout>
</template>

<style lang="scss" scoped></style>
