<script>
    import { createEventDispatcher, onMount } from "svelte";
    import Button, { Label } from "@smui/button";
    import EyeCheckOutline from "svelte-material-icons/EyeCheckOutline.svelte";
    import CrosshairsGps from "svelte-material-icons/CrosshairsGps.svelte";
    import Timer from "svelte-material-icons/Timer.svelte";

    import { wakelockCb } from "../stores";
    import { say } from "../js/lib.js";
    import { summariseUpto } from "../js/dayRuns";
    import { backupRun } from "../js/persistence";
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
                doBackup();
                mkAnnouncement();
            } else {
                // end of run
                let runMeta = summarise(state.list);
                let tmp = {
                    waypoints: state.waypoints,
                    completed: true,
                    ...runMeta
                };
                console.log("FINISHED", tmp);
                stopGeolocation();
                clearInterval(interval);
                say({ txt: "Finished, well done" });
                dispatch("finished", tmp);
            }
        }
    }, 1000);

    const doBackup = () => {
        let runMeta = summariseUpto(state.list, time / 60);
        let run = {
            title: state.title,
            waypoints: state.waypoints,
            completed: false,
            start: state.start,
            backup: new Date(),
            ...runMeta
        };
        backupRun(run);
    };

    const abandon = () => {
        let runMeta = summariseUpto(state.list, time / 60);
        let tmp = {
            waypoints: state.waypoints,
            completed: false,
            ...runMeta
        };
        console.log("Abandon", tmp);
        stopGeolocation();
        clearInterval(interval);
        say({ txt: "Run abandoned" });
        dispatch("finished", tmp);
    };

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
        // install an event listener for visibility (so that we can recreate the wake lock)
        monitorVisibility(onVisibleAgain);
    });
</script>

<style>
    .banner {
        position: relative;
    }
    .counter {
        font-size: 120px;
    }
    .elapsed {
        min-width: 4ch;
    }
</style>

<div class="m-3 flex flex-col flex-grow justify-between">
    <div class="flex flex-col">
        <div class="flex flex-row items-center justify-between text-2xl">
            <div class="capitalize">{state.list[section].type}</div>
            <div class="flex flex-row items-center">
                <Timer />
                <span class="elapsed ml-2">{ppTime(time)}</span>
            </div>
        </div>

        <div class="banner flex flex-row items-center justify-center">
            <div class="counter">
                {ppTime(state.list[section].accTime - time)}
            </div>
        </div>

        <Activity {section} list={state.list} />
    </div>

    <div class="self-center">
        <Button variant="raised" class="danger" on:click={abandon}>
            <Label>Abandon</Label>
        </Button>
        <span>Your workout will be saved</span>
    </div>
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
        Spoken announcements require the phone to stay on. Leave this app
        visible and do not press your phone's sleep button.
    </footer>
{/if}
