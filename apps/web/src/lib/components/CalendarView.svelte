<script lang="ts">
  console.log("🚀 Building infinite scroll calendar...");

  let message = $state("Testing basic calendar rendering");
  let testWeeks = $state([
    { id: 1, name: "Week 41", dates: "Oct 6-12" },
    { id: 2, name: "Week 42", dates: "Oct 13-19" }
  ]);
  
  console.log("✅ Basic calendar state initialized");
</script>

<div class="bg-white p-6 rounded-lg shadow">
  <h2 class="text-lg font-bold mb-4">Calendar Test</h2>
  <p class="text-gray-600 mb-4">{message}</p>
  
  <div class="space-y-2">
    {#each testWeeks as week}
      <div class="p-3 border rounded">
        <div class="font-medium">{week.name}</div>
        <div class="text-sm text-gray-600">{week.dates}</div>
      </div>
    {/each}
  </div>
  
  <div class="mt-4 p-3 bg-green-50 rounded">
    <p class="text-green-800">✅ Component is rendering!</p>
  </div>
</div>