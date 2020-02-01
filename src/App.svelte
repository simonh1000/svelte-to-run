<script>
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
    import { startGeolocation, stopGeolocation } from "./js/geolocation";

    import Header from "./Components/Header.svelte";
    import TabBar from "./Components/TabBar.svelte";
    import Ready from "./NextRun/Ready.svelte";
    import Active from "./NextRun/Active.svelte";
    import Finished from "./NextRun/Finished.svelte";
    import PastRuns from "./PastRuns/PastRuns.svelte";

    const initialiseReady = function() {
        startGeolocation(geoCb);
        let history = getRunsData();
        const initialModel = mkReadyModel(history);
    };

    const initialisePastRuns = function() {
        stopGeolocation();
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
</script>

<style>
    .main {
        max-width: 840px;
        margin: 0 auto;
    }
</style>

<div class="flex flex-col h-screen main">
    <Header />

    {#if $state.state == READY}
        <TabBar state={$state.state} {tabClick} />
        <Ready
            class="flex-grow flex flex-col"
            state={$state}
            on:start={ready2Active} />
    {/if}

    {#if $state.state == ACTIVE}
        <Active state={$state} on:finished={active2Finished} />
    {/if}

    {#if $state.state == FINISHED}
        <TabBar state={$state.state} {tabClick} />
        <Finished state={$state} onSaveDistance={initialisePastRuns} />
    {/if}

    {#if $state.state == PAST_RUNS}
        <TabBar state={$state.state} {tabClick} />
        <PastRuns state={$state} />
    {/if}
</div>
