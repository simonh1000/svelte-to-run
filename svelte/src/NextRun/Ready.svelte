<script>
    import { onMount, createEventDispatcher } from "svelte";
    import Button from "@smui/button";

    import { enableSound } from "../js/lib.js";
    import Activity from "./Activity.svelte";

    export let state;

    let warmUp = false;

    const dispatch = createEventDispatcher();
    const mkDispatch = minute => {
        dispatch("start", { minute, warmUp });
    };

    // the sound will not work on some systems unless it is triggered by a user action
    // attach a listener (this could be done in svelte?)
    onMount(() => {
        enableSound();
    });
</script>

<style>
    h2 {
        color: red;
    }
    .summary {
        margin: 10px 0;
    }
    .debug {
        margin-top: 20px;
    }
</style>

<div class="flex-col flex-center">
    <h2>{state.title}</h2>

    <Button
        id="start-button"
        variant="raised"
        on:click={() => mkDispatch(60)}
        style="padding: 20px; min-width: 36px; height: auto">
        <span class="start-button">Start workout</span>
    </Button>

    <section class="summary">
        {state.list
            .filter(item => item.type == 'run')
            .reduce((acc, item) => acc + item.time, 0)} minutes running
    </section>

    <div>
        <input type="checkbox" id="warm-up" bind:checked={warmUp} />
        <label for="warm-up">Add 5 mins warm up</label>
    </div>

    <Activity section="-1" list={state.list} />
</div>

<div class="debug flex-row">
    <Button id="debug-button" on:click={() => mkDispatch(10)}>
        Debug mode
    </Button>
    <div style="overflow: hidden">{JSON.stringify(state.location)}</div>
</div>
