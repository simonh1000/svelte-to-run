<script>
    import { onMount } from "svelte";

    import RunSummary from "./PastRun";

    export let state;
</script>

<style>
    .container {
        padding: 0 10px;
    }
    table {
        width: 100%;
        margin-top: 20px;
        margin-left: -10px;
        margin-right: -10px;
    }
    th {
        padding: 2px 10px;
        text-align: left;
    }
</style>

<div class="container flex flex-col flex-grow">
    {#if state.history.length > 0}
        <table>
            <thead>
                <th>Date</th>
                <th>Run (mins)</th>
                <th>Km</th>
            </thead>
            {#each state.history as run}
                <RunSummary {run} />
            {/each}
        </table>
    {:else}
        <h3 class="text-xl text-center font-bold mt-6">No runs yet</h3>
    {/if}
</div>

{#if state.debug}
    <footer class="debug flex flex-row justify-between flex-shrink-0">
        <a
            download="backup.json"
            href="data:application/json,{JSON.stringify(state.history)}">
            Backup
        </a>
    </footer>
{/if}
