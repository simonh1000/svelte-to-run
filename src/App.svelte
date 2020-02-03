<script>
    import { getRunsData } from "./js/persistence";
    import {
        state,
        mkReadyModel,
        ready2Active,
        active2Finished,
        mkPastRunsModel,
        READY,
        SPLASH,
        ACTIVE,
        FINISHED,
        PAST_RUNS,
        geoCb
    } from "./stores";
    import { startGeolocation, stopGeolocation } from "./js/geolocation";

    import Header from "./Components/Header.svelte";
    import TabBar from "./Components/TabBar.svelte";
    import Splash from "./Components/Splash.svelte";
    import Ready from "./NextRun/Ready.svelte";
    import Active from "./NextRun/Active.svelte";
    import Finished from "./NextRun/Finished.svelte";
    import PastRuns from "./PastRuns/PastRuns.svelte";

    let history = getRunsData();

    const initialiseReady = function() {
        startGeolocation(geoCb);
        const initialModel = mkReadyModel(history);
    };

    const initialisePastRuns = function(hs) {
        stopGeolocation();
        const initialModel = mkPastRunsModel(hs);
    };

    let tabClick = nextState => {
        if (nextState == READY) {
            initialiseReady();
        } else {
            initialisePastRuns(history);
        }
    };
    if (history.length > 0) {
        initialiseReady();
    }
</script>

<style>
    .main {
        max-width: 840px;
        margin: 0 auto;
        padding: 0 15px;
        /* ensure debug shows on mobile above fold */
        min-height: -moz-available; /* WebKit-based browsers will ignore this. */
        min-height: -webkit-fill-available; /* Mozilla-based browsers will ignore this. */
        min-height: fill-available;
    }
</style>

<Header />
<div class="flex flex-col main">

    {#if $state.state == SPLASH}
        <Splash onAccept={initialiseReady} />
    {/if}

    {#if $state.state == READY}
        <TabBar state={$state.state} {tabClick} />
        <Ready state={$state} on:start={ready2Active} />
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
