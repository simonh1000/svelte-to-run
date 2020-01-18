<script>
    import { onMount, createEventDispatcher } from "svelte";

    import { enableSound } from "../lib.js";
    import Activity from "../Components/Activity.svelte";

    export let state;
    let warmUp = false;

    const dispatch = createEventDispatcher();
    const debug = () => mkDispatch(10);
    const start = () => mkDispatch(60);
    const mkDispatch = minute => {
        dispatch("start", { minute, warmUp });
    };

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
    <button id="start-button" class="button" on:click={start}>Start</button>
</div>

<button id="debug-button" on:click={debug}>Debug mode</button>

<div>{JSON.stringify(state.location)}</div>
