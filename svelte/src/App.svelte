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

    import Header from "./Components/Header.svelte";
    import TabBar from "./Components/TabBar.svelte";
    import Ready from "./NextRun/Ready.svelte";
    import Active from "./NextRun/Active.svelte";
    import Finished from "./NextRun/Finished.svelte";
    import PastRuns from "./PastRuns/PastRuns.svelte";

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
    <Header />

    {#if $state.state == READY}
        <TabBar state={$state.state} {tabClick} />
        <Ready state={$state} on:start={ready2Active} />
    {/if}

    {#if $state.state == ACTIVE}
        <Active state={$state} on:finished={active2Finished} />
    {/if}

    {#if $state.state == FINISHED}
        <TabBar state={$state.state} {tabClick} />
        <Finished state={$state} />
    {/if}

    {#if $state.state == PAST_RUNS}
        <TabBar state={$state.state} {tabClick} />
        <PastRuns state={$state} />
    {/if}
</main>
