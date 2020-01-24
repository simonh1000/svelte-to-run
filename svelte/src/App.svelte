<script>
    import TopAppBar, { Row, Section, Title } from "@smui/top-app-bar";
    import Tab, { Icon, Label } from "@smui/tab";
    import Button from "@smui/button";
    import IconButton from "@smui/icon-button";

    import { getRunsData } from "./js/persistence";
    import {
        state,
        mkReadyModel,
        ready2Active,
        active2Finished,
        mkPastRunsModel,
        READY,
        ACTIVE,
        FINISHED,
        PAST_RUNS,
        geoCb
    } from "./stores";
    import { startGeolocation } from "./js/geolocation";

    import Ready from "./Components/Ready.svelte";
    import Active from "./Components/Active.svelte";
    import Finished from "./Components/Finished.svelte";
    import PastRuns from "./Components/PastRuns.svelte";
    import TabBar from "./Components/TabBar.svelte";

    const initialiseReady = function() {
        let history = getRunsData();
        const initialModel = mkReadyModel(history);
        startGeolocation(geoCb);
    };

    const initialisePastRuns = function() {
        let history = getRunsData();
        const initialModel = mkPastRunsModel(history);
    };

    let tabClick = nextState => {
        if (nextState == READY) {
            initialiseReady();
        } else {
            initialisePastRuns();
        }
    };
    initialiseReady();
    // initialisePastRuns();
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
</style>

<main>
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

    {#if $state.state == READY}
        <TabBar {tabClick} />
        <Ready state={$state} on:start={ready2Active} />
    {/if}

    {#if $state.state == ACTIVE}
        <Active state={$state} on:finished={active2Finished} />
    {/if}

    {#if $state.state == FINISHED}
        <TabBar {tabClick} />
        <Finished state={$state} />
    {/if}

    {#if $state.state == PAST_RUNS}
        <TabBar {tabClick} />
        <PastRuns state={$state} />
    {/if}
</main>
