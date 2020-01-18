<script>
    import { createEventDispatcher } from "svelte";
    import Activity from "./Components/Activity.svelte";

    export let state;
    let time = 0;
    let section = 0; // array index of run

    const dispatch = createEventDispatcher();

    setInterval(() => {
        time++;
        if (time > state.list[section].accTime) {
            section++;
        }
    }, 1000);
</script>

<style>
    .xlarge {
        font-size: 48px;
    }
</style>

<h2>Active</h2>
{section}
<Activity list={state.list} />

<div class="xlarge">{time}</div>

<button disabled>Pause</button>
<button disabled>Stop</button>

<div>{JSON.stringify(state.waypoints)}</div>
