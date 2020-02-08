<script>
    import { getRunsData, addLatestRun } from "./js/persistence";
    import { dayRuns, getNextRun, dayRun2Run, summarise } from "./js/dayRuns";

    import {
        state,
        setHistory,
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

    // load past runs from localstorage, and put in state
    setHistory(getRunsData());

    // state changes

    const initialiseReady = function() {
        let nextRun = getNextRun($state.history);

        if (nextRun < dayRuns.length) {
            startGeolocation(geoCb);
            mkReadyModel(nextRun);
        } else {
            // there are no more runs left to offer user
            initialisePastRuns();
        }
    };

    const initialisePastRuns = () => {
        stopGeolocation();
        mkPastRunsModel();
    };

    // Called by Finish
    const onRunCompleted = run => {
        const history = addLatestRun(run);
        setHistory(history);
        initialisePastRuns();
    };

    // helpers for view.

    // Feels like there should be a better way based on ractive variables
    const checkAllDone = hs => getNextRun(hs) >= dayRuns.length;

    let tabClick = nextState => {
        if (nextState == READY) {
            initialiseReady();
        } else {
            initialisePastRuns(history);
        }
    };

    // if we have some runs, the user must have passed via SPLASH already
    // so let's switch to that
    if ($state.history.length > 0) {
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
    {#if $state.state != ACTIVE && $state.state != SPLASH && !checkAllDone($state.history)}
        <TabBar state={$state.state} {tabClick} />
    {/if}

    {#if $state.state == SPLASH}
        <Splash onAccept={initialiseReady} />
    {/if}

    {#if $state.state == READY}
        <Ready state={$state} on:start={ready2Active} />
    {/if}

    {#if $state.state == ACTIVE}
        <Active state={$state} on:finished={active2Finished} />
    {/if}

    {#if $state.state == FINISHED}
        <Finished state={$state} {onRunCompleted} />
    {/if}

    {#if $state.state == PAST_RUNS}
        {#if checkAllDone($state.history)}
            <h3 class="text-xl">All Runs completed</h3>
        {/if}
        <PastRuns state={$state} />
    {/if}
</div>
