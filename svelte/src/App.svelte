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
    import TopAppBar, { Row, Section, Title } from "@smui/top-app-bar";
    import IconButton from "@smui/icon-button";
    import Button, { Label, Icon } from "@smui/button";
    import Fab from "@smui/fab";

    let secondaryColor = false;

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

<div class="top-app-bar-container">
    <TopAppBar
        variant="static"
        color={secondaryColor ? 'secondary' : 'primary'}>
        <Row>
            <Section>
                <IconButton class="material-icons">menu</IconButton>
                <Title>Static</Title>
            </Section>
        </Row>
    </TopAppBar>
</div>

<Fab on:click={() => alert('Clicked!')} extended>
    <Icon class="material-icons" style="margin-right: 12px;">favorite</Icon>
    <Label>Extended FAB</Label>
</Fab>

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
