<script setup>
import SidePanel from "@/components/SidePanel.vue"
import EventsLayout from "@/layouts/EventsLayout.vue"
</script>

<template>
    <EventsLayout>
        <template #sidePanel>
            <SidePanel />
        </template>
    </EventsLayout>
</template>

<style lang="scss" scoped></style>
