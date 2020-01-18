<script>
    import { onMount, createEventDispatcher } from "svelte";
    import Button from "@smui/button";

    import { enableSound } from "./lib.js";
    import Activity from "./Components/Activity.svelte";

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
    .buttons {
        display: flex;
        align-items: stretch;
    }
    .button {
        display: flex;
        border: 1px solid grey;
        background-color: cornflowerblue;
        padding: 5px;
    }
    .button + .button {
        margin-left: 5px;
    }
</style>

<h2>Ready to start: {state.title}</h2>

<Activity section="-1" list={state.list} />

<div class="buttons">
    <div class="button">
        <input type="checkbox" id="warm-up" bind:checked={warmUp} />
        <label for="warm-up">Add 5 mins warm up</label>
    </div>
    <Button id="start-button" variant="raised" on:click={() => mkDispatch(60)}>
        Start
    </Button>
</div>

<Button id="debug-button" on:click={() => mkDispatch(10)}>Debug mode</Button>

<div>{JSON.stringify(state.location)}</div>
