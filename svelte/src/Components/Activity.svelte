<script>
    export let list;
    export let section;

    let mkClass = function(selected, type, idx) {
        let col = type == "run" ? "red" : "white";
        return idx == selected ? col + " selected" : col;
    };
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
    .selected {
        border: 2px solid blue;
    }
    .red {
        background-color: red;
    }
    .white {
        background-color: white;
    }
</style>

<div class="schema-items">
    {#each list as item, idx}
        <div
            class={mkClass(section, item.type, idx)}
            style="flex-grow:{item.time}">
            {item.time}
        </div>
    {/each}
</div>
