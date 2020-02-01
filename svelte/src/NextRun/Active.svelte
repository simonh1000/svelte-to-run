<script>
    import { createEventDispatcher, onMount } from "svelte";

    import { say } from "../js/lib.js";
    import { requestWakeLock, monitorVisibility } from "../js/wakelock.js";
    import { ppTime } from "../js/view-helpers";
    import { stopGeolocation } from "../js/geolocation";
    import Activity from "./Activity.svelte";

    export let state;
    let time = 0;
    let section = 0; // array index of run

    const dispatch = createEventDispatcher();

    let interval = setInterval(() => {
        time++;
        if (time > state.list[section].accTime) {
            if (section + 1 < state.list.length) {
                // end of section
                section++;
                mkAnnouncement();
            } else {
                // end of run
                console.log("FINISHED");
                stopGeolocation();
                clearInterval(interval);
                say({ txt: "Finished, well done" });
                // this returns the ful list of runs, but we don't need it at present
                dispatch("finished", { waypoints: state.waypoints });
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

    const handleWakeLock = evt => {
        console.log(evt.tag, evt.payload);
    };
    const onVisibleAgain = () => {
        requestWakeLock(handleWakeLock);
    };

    onMount(() => {
        mkAnnouncement();
        requestWakeLock(handleWakeLock);
        monitorVisibility(onVisibleAgain);
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

<div class="m-3">
    <div>{ppTime(time)}</div>

    <div class="banner flex flex-row items-center justify-center">
        <div class="type">{state.list[section].type}</div>
        <div class="counter">{ppTime(state.list[section].accTime - time)}</div>
    </div>

    <Activity {section} list={state.list} />

    <!-- <div>
    <button disabled>Pause</button>
    <button disabled>Stop</button>
</div> -->

    <div>{state.waypoints.length + ' waypoints collected'}</div>
    <!-- <small>{JSON.stringify(state.waypoints)}</!-->

</div>
