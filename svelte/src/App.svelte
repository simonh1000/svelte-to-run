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
    import Tab, { Icon, Label } from "@smui/tab";
    import TabBar from "@smui/tab-bar";
    import Button from "@smui/button";

    let secondaryColor = false;
    let active = "Home";

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
    section > div {
        margin-bottom: 40px;
    }
</style>

<div class="top-app-bar-container">
    <div>
        <TabBar tabs={['Home', 'Merchandise', 'About Us']} let:tab bind:active>
            <!-- Notice that the `tab` property is required! -->
            <Tab {tab}>
                <Label>{tab}</Label>
            </Tab>
        </TabBar>

        <div style="margin-top: 15px;">
            Programmatically select:
            {#each ['Home', 'Merchandise', 'About Us'] as tab}
                <Button on:click={() => (active = tab)}>
                    <Label>{tab}</Label>
                </Button>
            {/each}
        </div>

        <pre class="status">Selected: {active}</pre>
    </div>
</div>

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
