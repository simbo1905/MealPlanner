<script lang="ts">
  import { onMount } from 'svelte';

  let count = $state(0);

  console.log('[Svelte] Component created');

  onMount(() => {
    console.log('[Svelte] Component mounted - Svelte is running!');
    return () => {
      console.log('[Svelte] Component destroyed');
    };
  });

  function handleClick() {
    count++;
    console.log('[Svelte] Button clicked, count:', count);
  }
</script>

<div style="padding: 2rem;">
  <h1 style="color: #ff3e00;">Hello Svelte in JavaFX! 🎉</h1>
  
  <div style="margin: 2rem 0;">
    <p style="font-size: 2rem; font-weight: bold;">Count: {count}</p>
    <button 
      onclick={handleClick}
      style="
        padding: 1rem 2rem; 
        font-size: 1.2rem; 
        cursor: pointer; 
        background: #ff3e00; 
        color: white; 
        border: none; 
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      "
    >
      Click me!
    </button>
  </div>
  
  <p style="color: #666; margin-top: 2rem;">
    ✅ Svelte 5 with runes ($state)<br>
    ✅ JavaFX WebView integration<br>
    ✅ Console bridge (check terminal)<br>
    ✅ Interactive counter demo
  </p>
</div>
