<script>
    import TopAppBar, { Row, Section, Title } from "@smui/top-app-bar";
    import Tab, { Icon, Label } from "@smui/tab";
    import TabBar from "@smui/tab-bar";
    import Button from "@smui/button";
    import IconButton from "@smui/icon-button";

    import { getRunsData } from "./lib.js";
    import {
        state,
        mkReadyModel,
        switch2Ready,
        ready2Active,
        active2Finished,
        READY,
        ACTIVE,
        FINISHED
    } from "./stores";

    import Ready from "./Components/Ready.svelte";
    import Active from "./Components/Active.svelte";
    import Finished from "./Components/Finished.svelte";
    let tabs = [
        { title: "Activities", state: READY },
        { title: "Past runs", state: FINISHED }
    ];
    let active = "Activities";

    function initialiseReady() {
        let history = getRunsData();
        const initialModel = mkReadyModel(history);
        switch2Ready(initialModel);
    }

    let tabClick = nextState => {
        if (nextState == READY) {
            initialiseReady();
        } else {
            active2Finished();
        }
    };
    initialiseReady();
</script>

<style>
    main {
        /* text-align: center; */
        padding: 1em;
        max-width: 840px;
        margin: 0 auto;
    }

    @media (min-width: 640px) {
        main {
            max-width: none;
        }
    }
    section > div {
        margin-bottom: 40px;
    }
</style>

<TopAppBar variant="static" color="primary">
    <Row>
        <Section>
            <Title>
                <Icon class="material-icons">trending_up</Icon>
                Start to Run
            </Title>

        </Section>
    </Row>
</TopAppBar>

<div class="top-app-bar-container">
    <TabBar {tabs} let:tab>
        <!-- Notice that the `tab` property is required! -->
        <Tab {tab} on:click={() => tabClick(tab.state)}>
            <Label>{tab.title}</Label>
        </Tab>
    </TabBar>
</div>

<main>

    {#if $state.state == READY}
        <Ready state={$state} on:start={ready2Active} />
    {/if}

    {#if $state.state == ACTIVE}
        <Active state={$state} on:finished={active2Finished} />
    {/if}

    {#if $state.state == FINISHED}
        <Finished state={$state} />
    {/if}
</main>
