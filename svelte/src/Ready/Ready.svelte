<script>
    import { onMount, createEventDispatcher } from "svelte";

    import { enableSound } from "../../../elm/src/lib.js";
    import Activity from "../Components/Activity.svelte";

    export let state;

    const dispatch = createEventDispatcher();
    const start = () => {
        dispatch("start");
    };

    onMount(() => {
        enableSound();
    });
</script>

<h2>Ready to start: {state.title}</h2>

<Activity section="-1" list={state.list} />

<button>Add 5 mins walking</button>
<button>Debug mode</button>
<button id="start-button" on:click={start}>Start</button>

<div>{JSON.stringify(state.location)}</div>
