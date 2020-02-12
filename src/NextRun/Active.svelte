<script>
    import { createEventDispatcher, onMount } from "svelte";
    import EyeCheckOutline from "svelte-material-icons/EyeCheckOutline.svelte";
    import CrosshairsGps from "svelte-material-icons/CrosshairsGps.svelte";
    import Timer from "svelte-material-icons/Timer.svelte";

    import { wakelockCb } from "../stores";
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

    const onVisibleAgain = () => {
        requestWakeLock(wakelockCb);
    };

    onMount(() => {
        mkAnnouncement();
        requestWakeLock(wakelockCb);
        monitorVisibility(onVisibleAgain);
    });
</script>

<style>
    .banner {
        position: relative;
    }
    .counter {
        font-size: 90px;
    }
    .elapsed {
        min-width: 4ch;
    }
</style>

<div class="m-3 flex flex-col flex-grow">
    <div class="flex flex-row items-center justify-between text-2xl">
        <div class="capitalize">{state.list[section].type}</div>
        <div class="flex flex-row items-center">
            <Timer />
            <span class="elapsed ml-2">{ppTime(time)}</span>
        </div>
    </div>

    <div class="banner flex flex-row items-center justify-center">
        <div class="counter">{ppTime(state.list[section].accTime - time)}</div>
    </div>

    <Activity {section} list={state.list} />
</div>

{#if state.debug}
    <footer class="debug flex flex-row justify-between flex-shrink-0">
        <div>{state.waypoints.length + ' waypoints collected'}</div>
        {#if state.wakeLock}
            <span class="icon-container">
                <EyeCheckOutline />
            </span>
        {/if}
        {#if state.waypoints}
            <span class="icon-container">
                <CrosshairsGps />
            </span>
        {/if}
    </footer>
{:else}
    <footer class="bg-red-200 mb-5 p-3">
        The spoken announcements require the phone to stay on. Leave this
        browser window visible and do not press the sleep button.
    </footer>
{/if}
