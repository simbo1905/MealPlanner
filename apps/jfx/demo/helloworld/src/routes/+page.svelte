<script lang="ts">
  import { onMount } from 'svelte';

  let count = $state(0);

  console.log('[Svelte] Component created');

  onMount(() => {
    console.log('[Svelte] Component mounted');
    return () => {
      console.log('[Svelte] Component destroyed');
    };
  });

  function handleClick() {
    count++;
    console.log('[Svelte] Button clicked, count:', count);
  }
</script>

<div style="padding: 2rem; font-family: system-ui;">
  <h1>Hello Svelte in JavaFX!</h1>
  
  <div style="margin: 2rem 0;">
    <p style="font-size: 1.5rem;">Count: {count}</p>
    <button 
      onclick={handleClick}
      style="padding: 1rem 2rem; font-size: 1rem; cursor: pointer; background: #ff3e00; color: white; border: none; border-radius: 4px;"
    >
      Click me!
    </button>
  </div>
  
  <p style="color: #666;">Check the Java console for lifecycle logs</p>
</div>
