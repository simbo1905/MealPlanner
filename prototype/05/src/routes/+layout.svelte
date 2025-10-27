<script lang="ts">
  import { type Snippet } from "svelte"
  import "../app.css"
  import { Calendar, ShoppingCart } from 'lucide-svelte'

  const { children } = $props<{ children: Snippet }>()
  
  let activeTab = $state<'calendar' | 'shopping'>('calendar')

  if (typeof window !== 'undefined') {
    (window as any).__activeTab = {
      get: () => activeTab,
      set: (tab: 'calendar' | 'shopping') => { activeTab = tab }
    }
  }
</script>

<div class="flex flex-col h-screen bg-gray-50">
  <div class="border-b border-gray-200 bg-white shadow-sm">
    <div class="flex">
      <button
        onclick={() => activeTab = 'calendar'}
        class={`flex-1 flex items-center justify-center gap-2 py-3 font-semibold transition-colors ${
          activeTab === 'calendar'
            ? 'text-teal-600 border-b-2 border-teal-600'
            : 'text-gray-500 hover:text-gray-700'
        }`}
      >
        <Calendar class="w-5 h-5" />
        <span>Calendar</span>
      </button>
      <button
        onclick={() => activeTab = 'shopping'}
        class={`flex-1 flex items-center justify-center gap-2 py-3 font-semibold transition-colors ${
          activeTab === 'shopping'
            ? 'text-teal-600 border-b-2 border-teal-600'
            : 'text-gray-500 hover:text-gray-700'
        }`}
      >
        <ShoppingCart class="w-5 h-5" />
        <span>Shopping</span>
      </button>
    </div>
  </div>

  <div class="flex-1 overflow-hidden">
    {@render children()}
  </div>
</div>
