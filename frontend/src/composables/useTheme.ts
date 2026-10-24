import { ref } from 'vue'

/**
 * 主题管理组合式函数 (useTheme)
 *
 * 遵循极简主义规范 (Linear / Vercel 风格)：
 * 1. 默认为白色系 (Light mode)；
 * 2. 仅在用户显式设置并存储为 'dark' 时才使用深色系；
 * 3. 状态为单例全局共享，任何地方切换均全站实时响应。
 */

// 初始化判断：未显式设定为 'dark' 时，默认一律为白色系 (false)
const savedTheme = typeof window !== 'undefined' ? localStorage.getItem('theme') : null
const isDark = ref<boolean>(savedTheme === 'dark')

/**
 * 应用主题至 DOM 根节点
 */
function applyTheme(dark: boolean) {
  if (typeof document === 'undefined') return
  document.documentElement.classList.toggle('dark', dark)
  localStorage.setItem('theme', dark ? 'dark' : 'light')
}

/**
 * 切换明暗主题 (白色系 <-> 暗黑极客系，支持 View Transition 平滑淡入淡出)
 */
function toggleTheme() {
  const nextDark = !isDark.value

  // 若浏览器支持 View Transitions API，提供平滑交叉过渡
  if (typeof document !== 'undefined' && 'startViewTransition' in document) {
    ;(document as any).startViewTransition(() => {
      isDark.value = nextDark
      applyTheme(nextDark)
    })
  } else {
    isDark.value = nextDark
    applyTheme(nextDark)
  }
}

/**
 * 显式设定指定主题
 * @param theme 'light' | 'dark'
 */
function setTheme(theme: 'light' | 'dark') {
  isDark.value = theme === 'dark'
  applyTheme(isDark.value)
}

export function useTheme() {
  return {
    isDark,
    toggleTheme,
    setTheme
  }
}
