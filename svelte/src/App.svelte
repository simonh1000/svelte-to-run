<script>
    import {
        state,
        choosing2Ready,
        ready2Active,
        CHOOSING,
        READY,
        ACTIVE
    } from "./stores";
    import { startGeolocation } from "../../elm/src/lib.js";

    import Choosing from "./Choosing/Choosing.svelte";
    import Ready from "./Ready/Ready.svelte";
    import Active from "./Active.svelte";

    export let dayRuns;
</script>

<style>
    main {
        /* text-align: center; */
        padding: 1em;
        max-width: 840px;
        margin: 0 auto;
    }

    h1 {
        color: #ff3e00;
        text-transform: uppercase;
        font-size: 4em;
        font-weight: 100;
    }

    @media (min-width: 640px) {
        main {
            max-width: none;
        }
    }
</style>

<main>
    <h1>My Running app</h1>

    {#if $state.state == CHOOSING}
        <Choosing {dayRuns} on:selectRun={choosing2Ready} />
    {/if}

    {#if $state.state == READY}
        <Ready state={$state} on:start={ready2Active} />
    {/if}

    {#if $state.state == ACTIVE}
        <Active state={$state} />
    {/if}
</main>
