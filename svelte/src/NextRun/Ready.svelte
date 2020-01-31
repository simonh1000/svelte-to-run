<script>
    import { onMount, createEventDispatcher } from "svelte";
    import Button from "@smui/button";
    import CrosshairsGps from "svelte-material-icons/CrosshairsGps.svelte";
    import Run from "svelte-material-icons/Run.svelte";
    import Timer from "svelte-material-icons/Timer.svelte";

    import { enableSound } from "../js/lib.js";
    import Activity from "./Activity.svelte";

    export let state;

    let warmUp = false;

    const dispatch = createEventDispatcher();
    const mkDispatch = minute => {
        dispatch("start", { minute, warmUp });
    };

    const distance = state.list
        .filter(item => item.type == "run")
        .reduce((acc, item) => acc + item.time, 0);

    const time = state.list.reduce((acc, item) => acc + item.time, 0);

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
    .summary {
        margin: 15px 0;
    }
    .debug {
        margin-top: 15px;
    }
    .day-no {
        font-size: 24pt;
    }
</style>

<div class="ready flex-col flex-center">

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

    <section class="summary">
        <Run />
        {distance}
        <Timer class="" />
        {time}
    </section>

    <div>
        <input type="checkbox" id="warm-up" bind:checked={warmUp} />
        <label for="warm-up">Add 5 mins warm up</label>
    </div>

    <Activity section="-1" list={state.list} />
</div>

<div class="debug flex-row flex-spread">
    <Button id="debug-button" on:click={() => mkDispatch(10)}>
        Debug mode
    </Button>
    {#if state.location.coords}
        <span class="icon-container">
            <CrosshairsGps />
        </span>
    {/if}
</div>
<!-- {JSON.stringify(state.location)} -->
