<script>
    import {
        state,
        choosing2Ready,
        ready2Active,
        active2Finished,
        CHOOSING,
        READY,
        ACTIVE,
        FINISHED
    } from "./stores";

    import Ready from "./Ready.svelte";
    import Active from "./Active.svelte";
    import Finished from "./Finished.svelte";
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

    {#if $state.state == CHOOSING}No longer used{/if}

    {#if $state.state == READY}
        <Ready state={$state} on:start={ready2Active} />
    {/if}

    {#if $state.state == ACTIVE}
        <Active state={$state} on:finished={active2Finished} />
    {/if}

    {#if $state.state == FINISHED}
        <Finished state={$state} />
    {/if}
</main>
