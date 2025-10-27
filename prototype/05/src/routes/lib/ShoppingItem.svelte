<script lang="ts">
  import { Circle, CheckCircle2, Star } from 'lucide-svelte'
  import type { ShoppingItem } from './shoppingTypes'

  let {
    item,
    onToggleComplete,
    onToggleStar
  }: {
    item: ShoppingItem
    onToggleComplete: (id: string) => void
    onToggleStar: (id: string) => void
  } = $props()
</script>

<div
  class="rounded-2xl bg-neutral-900/60 ring-1 ring-white/5 px-4 py-3 flex items-center justify-between transition-all duration-150"
>
  <div class="flex items-center gap-3 flex-1 min-w-0">
    <button
      onclick={(e) => {
        e.stopPropagation()
        onToggleComplete(item.id)
      }}
      class="flex-shrink-0 w-11 h-11 flex items-center justify-center -ml-1"
      aria-label={item.completed ? 'Mark as incomplete' : 'Mark as complete'}
      role="checkbox"
      aria-checked={item.completed}
    >
      {#if item.completed}
        <CheckCircle2 class="w-6 h-6 text-teal-300" />
      {:else}
        <Circle class="w-6 h-6 text-white/60" />
      {/if}
    </button>
    <div class="flex-1 min-w-0">
      <div
        class={`text-base font-semibold transition-all duration-150 ${
          item.completed ? 'line-through text-white/40' : 'text-white'
        }`}
      >
        {item.text}
      </div>
    </div>
  </div>
  <button
    onclick={(e) => {
      e.stopPropagation()
      onToggleStar(item.id)
    }}
    class="flex-shrink-0 w-11 h-11 flex items-center justify-center -mr-1 transition-transform duration-100 active:scale-90"
    aria-label={item.starred ? 'Remove from favorites' : 'Add to favorites'}
    aria-pressed={item.starred}
  >
    <Star
      class={`w-5 h-5 transition-all duration-120 ${
        item.starred ? 'fill-white/60 text-white/60' : 'text-white/60'
      }`}
    />
  </button>
</div>
