<script>
    import { onMount, createEventDispatcher } from "svelte";
    import Button from "@smui/button";
    import CrosshairsGps from "svelte-material-icons/CrosshairsGps.svelte";
    import Run from "svelte-material-icons/Run.svelte";
    import Timer from "svelte-material-icons/Timer.svelte";

    import { addWarmUp, removeWarmUp } from "../stores";
    import { enableSound } from "../js/lib.js";
    import Activity from "./Activity.svelte";

    export let state;

    let warmUp = false;
    const toggleWarmUp = evt => {
        if (warmUp) {
            // remove warm up
            removeWarmUp();
        } else {
            addWarmUp();
        }
        warmUp = !warmUp;
    };

    const dispatch = createEventDispatcher();
    const mkDispatch = minute => {
        dispatch("start", { minute, warmUp });
    };

    const distance = state.list
        .filter(item => item.type == "run")
        .reduce((acc, item) => acc + item.time, 0);

    let time = state.list.reduce((acc, item) => acc + item.time, 0);

    // the sound will not work on some systems unless it is triggered by a user action
    // attach a listener (this could be done in svelte?)
    onMount(() => {
        enableSound();
    });
</script>

<style>
    .ready {
        margin-top: 15px;
    }
    .debug {
        margin-top: 15px;
    }
    .day-no {
        font-size: 24pt;
    }
</style>

<div class="ready flex flex-col flex-grow items-center overflow-auto">
    <Button
        id="start-button"
        variant="raised"
        on:click={() => mkDispatch(60)}
        style="padding: 20px; min-width: 36px; height: auto">
        <span class="start-button">
            Start workout
            <span class="smui-button--color-secondary day-no">
                {state.title + 1}
            </span>
        </span>
    </Button>

    <div class="mt-5 mb-2">
        <input
            id="warm-up"
            type="checkbox"
            checked={warmUp}
            on:change={toggleWarmUp} />
        <label for="warm-up">Optionally add 5 mins warm up</label>
    </div>

    <section class="m-2 flex flex-row items-center">
        <Run />
        <span class="ml-1 mr-4">{distance}</span>
        <Timer />
        <span class="ml-1">{time + (warmUp ? 5 : 0)}</span>
    </section>

    <Activity section="-1" list={state.list} />
</div>

<footer class="debug flex flex-row justify-between flex-shrink-0">
    <button id="debug-button" on:click={() => mkDispatch(10)}>
        Debug mode
    </button>
    {#if state.location.coords}
        <span class="icon-container">
            <CrosshairsGps />
        </span>
    {/if}
</footer>
<!-- {JSON.stringify(state.location)} -->
