<script>
    export let list;
    // console.log(document.querySelector(".activity"));
</script>

<style>
    .activity {
        display: flex;
        flex-direction: column;
    }
    .schema-items {
        display: flex;
        height: 60px;
    }
    .schema-items div {
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .red {
        background-color: red;
    }
    .white {
        background-color: white;
    }
</style>

<div class="schema-items">
    {#each list as item}
        <div
            class={item.type == 'run' ? 'red' : 'white'}
            style="flex-grow: {item.time}">
            {item.time}
        </div>
    {/each}
</div>
