<script setup>
import HomePageLayout from "@/layouts/HomePageLayout.vue"
import SidePanel from "@/components/SidePanel.vue"
import Chat from "@/components/Chat.vue"
</script>

<template>
    <HomePageLayout>
        <template #sidePanel>
            <SidePanel />
        </template>
        <Chat />
    </HomePageLayout>
</template>

<style lang="scss" scoped></style>
