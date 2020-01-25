<script>
    import TabBar from "@smui/tab-bar";
    import Tab, { Icon, Label } from "@smui/tab";
    import { onMount } from "svelte";

    import { READY, PAST_RUNS } from "../stores";

    export let tabClick;
    export let state;
    let active;

    let tabs = [
        { title: "Activities", state: READY },
        { title: "Past runs", state: PAST_RUNS }
    ];
    onMount(() => {
        active = state == PAST_RUNS ? tabs[1] : tabs[0];
    });
</script>

<div class="top-app-bar-container">
    <TabBar {tabs} let:tab {active}>
        <!-- Notice that the `tab` property is required! -->
        <Tab {tab} on:click={() => tabClick(tab.state)}>
            <Label>{tab.title}</Label>
        </Tab>
    </TabBar>
</div>
