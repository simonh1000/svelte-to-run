<script>
    import { createEventDispatcher, onMount } from "svelte";
    import { requestWakeLock, say } from "../../elm/src/lib.js";
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
                mkAnnouncement();
            }
        }
    }, 1000);

    const mkAnnouncement = () => {
        let item = state.list[section];
        let txt = `${item.type} for ${item.time} ${
            item.time == 1 ? "minute" : "minutes"
        }`;
        say({ ...item, txt });
    };

    onMount(() => {
        mkAnnouncement();
        requestWakeLock();
    });
</script>

<style>
    .banner {
        position: relative;
    }
    .type {
        position: absolute;
        left: 0;
        font-size: 32px;
    }
    .counter {
        font-size: 78px;
    }
</style>

<h2>Active</h2>

<div class="banner flex-row flex-center justify-center">
    <div class="type">{state.list[section].type}</div>
    <div class="counter">{state.list[section].accTime - time}</div>
</div>

<Activity {section} list={state.list} />

<!-- <div>
    <button disabled>Pause</button>
    <button disabled>Stop</button>
</div> -->

<div>{state.waypoints.length + ' waypoints collected'}</div>
<!-- <small>{JSON.stringify(state.waypoints)}</!-->
