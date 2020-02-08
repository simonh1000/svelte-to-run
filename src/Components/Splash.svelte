<script>
    import Button from "@smui/button";

    export let onAccept;
</script>

<style>
    a {
        text-decoration: underline;
    }
</style>

<h1 class="text-center text-4xl mt-4">Start to Run</h1>

<ul class="list-disc list-outside ml-4 mt-4 mb-4">
    <li class="mb-2">
        Build up your running times gradually, and keep track of the distance
        you covered whether outside or on a treadmill.
    </li>
    <li class="mb-2">
        This app uses cutting-edge browser features, and
        <span class="font-bold">works best with Chrome on Android</span>
        . If you experience a technical issue or have a feature request, please
        report on
        <a href="https://github.com/simonh1000/svelte-to-run">Github</a>
        .
    </li>
    <li class="mb-2 font-small">
        <span class="font-bold">Disclaimer</span>
        Seek appropriate health advice before starting to run. The app collects
        no personal data - running data is stored on your phone. But it does use
        Google Analytics - see their
        <a href="https://policies.google.com/technologies/partner-sites">
            privacy policy
        </a>
        .
    </li>
</ul>

<div class="flex flex-row justify-center">
    <Button
        variant="raised"
        on:click={onAccept}
        style="padding: 20px; min-width: 36px; height: auto">
        <span>I accept</span>
    </Button>

</div>
