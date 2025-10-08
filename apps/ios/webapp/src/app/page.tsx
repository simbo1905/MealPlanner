'use client'

import React, { useEffect, useState } from 'react'

interface Recipe {
  id: string
  title: string
  image_url: string
  description: string
  notes: string
  total_time: number
}

declare global {
  interface Window {
    webkit?: {
      messageHandlers: {
        recipeHandler: {
          postMessage: (msg: any) => void
        }
        consoleLog: {
          postMessage: (msg: any) => void
        }
      }
    }
    onNativeRecipesUpdate?: (recipes: Recipe[]) => void
  }
}

function log(message: string, data?: any) {
  const msg = data ? `${message} ${JSON.stringify(data)}` : message
  console.log(msg)
  if (window.webkit?.messageHandlers?.consoleLog) {
    window.webkit.messageHandlers.consoleLog.postMessage(msg)
  }
}

export default function Home() {
  const [recipes, setRecipes] = useState<Recipe[]>([])
  const [buttonMounted, setButtonMounted] = useState(false)

  useEffect(() => {
    log('[React] Component mounted')
    
    window.onNativeRecipesUpdate = (newRecipes: Recipe[]) => {
      log('[React] Received recipes from native:', newRecipes)
      log('[React] Number of recipes received: ' + newRecipes.length)
      setRecipes(newRecipes)
    }

    log('[React] Checking for webkit bridge...')
    if (window.webkit?.messageHandlers?.recipeHandler) {
      log('[React] Bridge found, requesting recipe list')
      window.webkit.messageHandlers.recipeHandler.postMessage({ action: 'list' })
    } else {
      log('[React] ERROR: webkit bridge not available!')
    }
  }, [])

  useEffect(() => {
    if (!buttonMounted) {
      setButtonMounted(true)
      log('[React] Add Recipe button mounted')
    }
  }, [buttonMounted])

  useEffect(() => {
    log('[React] Recipes state updated, count: ' + recipes.length)
  }, [recipes])

  const addRecipe = () => {
    log('[React] ===== ADD BUTTON CLICKED =====')
    try {
      const title = prompt('Enter new recipe name') || 'Untitled'
      const description = prompt('Enter description') || ''
      log('[React] User input:', { title, description })
      if (window.webkit?.messageHandlers?.recipeHandler) {
        log('[React] Sending add recipe message')
        window.webkit.messageHandlers.recipeHandler.postMessage({
          action: 'add',
          recipe: { title, description, image_url: '', notes: '', total_time: 30 }
        })
      } else {
        log('[React] ERROR: Cannot add recipe, bridge not available')
      }
    } catch (err) {
      log('[React] ERROR in addRecipe: ' + err)
    }
  }

  const deleteRecipe = (id: string) => {
    if (window.webkit?.messageHandlers?.recipeHandler) {
      window.webkit.messageHandlers.recipeHandler.postMessage({
        action: 'delete',
        recipeId: id
      })
    }
  }

  return (
    <main style={{ padding: '20px', maxWidth: '600px', margin: '0 auto' }}>
      <h1 style={{ fontSize: '24px', marginBottom: '20px' }}>Hello WebView</h1>
      
      <button
        onClick={addRecipe}
        style={{
          backgroundColor: '#007AFF',
          color: 'white',
          border: 'none',
          padding: '10px 20px',
          borderRadius: '8px',
          fontSize: '16px',
          marginBottom: '20px',
          cursor: 'pointer'
        }}
      >
        ➕ Add Recipe
      </button>

      <ul style={{ listStyle: 'none', padding: 0 }}>
        {recipes.map((r) => (
          <li
            key={r.id}
            style={{
              backgroundColor: '#fff',
              padding: '15px',
              marginBottom: '12px',
              borderRadius: '8px',
              border: '1px solid #ddd'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div style={{ flex: 1 }}>
                <strong style={{ fontSize: '18px', display: 'block', marginBottom: '8px' }}>
                  {r.title}
                </strong>
                <p style={{ fontSize: '14px', color: '#666', margin: '0 0 8px 0' }}>
                  {r.description}
                </p>
                <div style={{ fontSize: '13px', color: '#888' }}>
                  ⏱️ {r.total_time} minutes
                </div>
              </div>
              <button
                onClick={() => deleteRecipe(r.id)}
                style={{
                  backgroundColor: '#ff3b30',
                  color: 'white',
                  border: 'none',
                  padding: '8px 12px',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  marginLeft: '12px'
                }}
              >
                🗑️
              </button>
            </div>
          </li>
        ))}
      </ul>

      {recipes.length === 0 && (
        <p style={{ color: '#888', textAlign: 'center' }}>No recipes yet</p>
      )}
    </main>
  )
}
