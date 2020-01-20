<script>
    import TabBar from "@smui/tab-bar";
    import Tab, { Icon, Label } from "@smui/tab";

    import { READY, PAST_RUNS } from "../stores";

    export let tabClick;

    let tabs = [
        { title: "Activities", state: READY },
        { title: "Past runs", state: PAST_RUNS }
    ];
    let active = "Activities";
</script>

<div class="top-app-bar-container">
    <TabBar {tabs} let:tab>
        <!-- Notice that the `tab` property is required! -->
        <Tab {tab} on:click={() => tabClick(tab.state)}>
            <Label>{tab.title}</Label>
        </Tab>
    </TabBar>
</div>
