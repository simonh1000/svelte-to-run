<script>
    import { createEventDispatcher } from "svelte";
    import Activity from "./Components/Activity.svelte";

    export let state;
    let time = 0;
    let section = 0; // array index of run

    const dispatch = createEventDispatcher();

    let interval = setInterval(() => {
        time++;
        if (time > state.list[section].accTime) {
            if (section + 1 == state.list.length) {
                console.log("FINISHED");
                clearInterval(interval);
                dispatch("finished");
            } else {
                section++;
            }
        }
    }, 1000);
</script>

<style>
    .xlarge {
        font-size: 48px;
    }
</style>

<h2>Active</h2>

<div class="xlarge">
    {state.list[section].accTime - time} {state.list[section].type}
</div>

<Activity {section} list={state.list} />

<button disabled>Pause</button>
<button disabled>Stop</button>

<div>{JSON.stringify(state.waypoints)}</div>
