<script>
    import { onMount, createEventDispatcher } from "svelte";

    import { enableSound } from "../../../elm/src/lib.js";
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
    .button {
        display: flex;
        border: 1px solid grey;
        background-color: cornflowerblue;
        padding: 5px;
    }
</style>

<h2>Ready to start: {state.title}</h2>

<Activity section="-1" list={state.list} />

<div class="button">
    <input type="checkbox" id="warm-up" bind:checked={warmUp} />
    <label for="warm-up">Add 5 mins warm up</label>
</div>

<button id="debug-button" on:click={debug}>Debug mode</button>
<button id="start-button" on:click={start}>Start</button>

<div>{JSON.stringify(state.location)}</div>
