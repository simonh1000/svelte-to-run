<script>
    import { onMount, createEventDispatcher } from "svelte";
    import Activity from "../Components/Activity.svelte";

    export let state;

    const dispatch = createEventDispatcher();
    function start() {
        dispatch("start");
    }
</script>

<h2>Ready to start: {state.title}</h2>

<Activity list={state.list} />

<button>Add 5 mins walking</button>
<button>Debug mode</button>
<button id="start-button" on:click={start}>Start</button>

<div>{JSON.stringify(state.location)}</div>
