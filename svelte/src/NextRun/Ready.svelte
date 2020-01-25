<script>
    import { onMount, createEventDispatcher } from "svelte";

    import Button from "@smui/button";
    import { startGeolocation } from "../js/geolocation";
    import { enableSound } from "../js/lib.js";
    import Activity from "./Activity.svelte";

    export let state;

    let warmUp = false;
    let active = true;

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
    .debug {
        margin-top: 20px;
    }
</style>

<div class="flex-col flex-center">
    <h2>{state.title}</h2>

    <Button id="start-button" variant="raised" on:click={() => mkDispatch(60)}>
        Start workout
    </Button>
    <div>
        {state.list
            .filter(item => item.type == 'run')
            .reduce((acc, item) => acc + item.time, 0)} minutes running
    </div>

    <Activity section="-1" list={state.list} />

    <div class="button">
        <input type="checkbox" id="warm-up" bind:checked={warmUp} />
        <label for="warm-up">Add 5 mins warm up</label>
    </div>
</div>

<div class="debug">
    <Button id="debug-button" on:click={() => mkDispatch(10)}>
        Debug mode
    </Button>
    <div>{JSON.stringify(state.location)}</div>
</div>
