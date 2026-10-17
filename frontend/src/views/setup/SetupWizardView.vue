<template>
  <div
    class="flex min-h-screen items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 p-4 dark:from-dark-900 dark:to-dark-800"
  >
    <div class="w-full max-w-xl">
      <!-- 头部 Logo 与标题 -->
      <div class="mb-8 text-center">
        <div
          class="mb-4 inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-primary-500 to-primary-600 shadow-lg"
        >
          <Icon name="cog" size="xl" class="text-white" />
        </div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Sub2API 初始配置</h1>
        <p class="mt-2 text-gray-500 dark:text-dark-400">单人专属自用版 · 首次部署仅需设置管理员账号</p>
      </div>

      <!-- 单页配置卡片 -->
      <div class="rounded-2xl bg-white p-8 shadow-xl dark:bg-dark-800">
        <div class="space-y-6">
          <div class="mb-6 text-center">
            <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
              设置管理员账号
            </h2>
            <p class="mt-1 text-sm text-gray-500 dark:text-dark-400">
              本地数据库与 Redis 默认已预置就绪，请设置您的管理员邮箱与密码后直接启动。
            </p>
          </div>

          <!-- 管理员邮箱 -->
          <div>
            <label class="input-label">{{ t('setup.admin.email') }}</label>
            <input
              v-model="formData.admin.email"
              type="email"
              class="input"
              placeholder="admin@example.com"
              :disabled="installing || installSuccess"
            />
          </div>

          <!-- 管理员密码 -->
          <div>
            <label class="input-label">{{ t('setup.admin.password') }}</label>
            <input
              v-model="formData.admin.password"
              type="password"
              class="input"
              :placeholder="t('setup.admin.passwordPlaceholder')"
              :disabled="installing || installSuccess"
            />
          </div>

          <!-- 确认密码 -->
          <div>
            <label class="input-label">{{ t('setup.admin.confirmPassword') }}</label>
            <input
              v-model="confirmPassword"
              type="password"
              class="input"
              :placeholder="t('setup.admin.confirmPasswordPlaceholder')"
              :disabled="installing || installSuccess"
            />
            <p
              v-if="confirmPassword && formData.admin.password !== confirmPassword"
              class="input-error-text mt-1 text-xs text-red-500"
            >
              {{ t('setup.admin.passwordMismatch') }}
            </p>
          </div>

          <!-- 高级设置展开按钮（默认折叠） -->
          <div class="pt-2">
            <button
              type="button"
              @click="showAdvanced = !showAdvanced"
              class="flex items-center text-sm font-medium text-primary-600 hover:text-primary-700 dark:text-primary-400"
            >
              <Icon :name="showAdvanced ? 'chevronDown' : 'chevronRight'" size="sm" class="mr-1" />
              {{ showAdvanced ? '收起高级设置（数据库与 Redis）' : '展开高级设置（数据库与 Redis）' }}
            </button>
          </div>

          <!-- 可选的高级设置区块 -->
          <div v-if="showAdvanced" class="space-y-6 border-t border-gray-100 pt-4 dark:border-dark-700">
            <!-- 数据库设置 -->
            <div class="space-y-4">
              <h3 class="text-sm font-semibold text-gray-900 dark:text-white">
                {{ t('setup.database.title') }}
              </h3>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label class="input-label">{{ t('setup.database.host') }}</label>
                  <input
                    v-model="formData.database.host"
                    type="text"
                    class="input"
                    placeholder="127.0.0.1"
                  />
                </div>
                <div>
                  <label class="input-label">{{ t('setup.database.port') }}</label>
                  <input
                    v-model.number="formData.database.port"
                    type="number"
                    class="input"
                    placeholder="5432"
                  />
                </div>
              </div>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label class="input-label">{{ t('setup.database.username') }}</label>
                  <input
                    v-model="formData.database.user"
                    type="text"
                    class="input"
                    placeholder="sub2api"
                  />
                </div>
                <div>
                  <label class="input-label">{{ t('setup.database.password') }}</label>
                  <input
                    v-model="formData.database.password"
                    type="password"
                    class="input"
                    :placeholder="t('setup.database.passwordPlaceholder')"
                  />
                </div>
              </div>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label class="input-label">{{ t('setup.database.databaseName') }}</label>
                  <input
                    v-model="formData.database.dbname"
                    type="text"
                    class="input"
                    placeholder="sub2api"
                  />
                </div>
                <div>
                  <label class="input-label">{{ t('setup.database.sslMode') }}</label>
                  <Select
                    v-model="formData.database.sslmode"
                    :options="sslModeOptions"
                    class="w-full"
                  />
                </div>
              </div>
              <button
                type="button"
                @click="testDatabaseConnection"
                :disabled="testingDb"
                class="btn btn-secondary w-full"
              >
                <Icon
                  v-if="dbConnected"
                  name="check"
                  size="md"
                  class="mr-2 text-green-500"
                  :stroke-width="2"
                />
                {{
                  testingDb
                    ? t('setup.status.testing')
                    : dbConnected
                      ? '数据库连接正常'
                      : t('setup.status.testConnection')
                }}
              </button>
            </div>

            <!-- Redis 设置 -->
            <div class="space-y-4 border-t border-gray-100 pt-4 dark:border-dark-700">
              <h3 class="text-sm font-semibold text-gray-900 dark:text-white">
                {{ t('setup.redis.title') }}
              </h3>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label class="input-label">{{ t('setup.redis.host') }}</label>
                  <input
                    v-model="formData.redis.host"
                    type="text"
                    class="input"
                    placeholder="127.0.0.1"
                  />
                </div>
                <div>
                  <label class="input-label">{{ t('setup.redis.port') }}</label>
                  <input
                    v-model.number="formData.redis.port"
                    type="number"
                    class="input"
                    placeholder="6379"
                  />
                </div>
              </div>
              <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label class="input-label">{{ t('setup.redis.password') }}</label>
                  <input
                    v-model="formData.redis.password"
                    type="password"
                    class="input"
                    :placeholder="t('setup.redis.passwordPlaceholder')"
                  />
                </div>
                <div>
                  <label class="input-label">{{ t('setup.redis.database') }}</label>
                  <input
                    v-model.number="formData.redis.db"
                    type="number"
                    class="input"
                    placeholder="0"
                  />
                </div>
              </div>
              <button
                type="button"
                @click="testRedisConnection"
                :disabled="testingRedis"
                class="btn btn-secondary w-full"
              >
                <Icon
                  v-if="redisConnected"
                  name="check"
                  size="md"
                  class="mr-2 text-green-500"
                  :stroke-width="2"
                />
                {{
                  testingRedis
                    ? t('setup.status.testing')
                    : redisConnected
                      ? 'Redis 连接正常'
                      : t('setup.status.testConnection')
                }}
              </button>
            </div>
          </div>
        </div>

        <!-- 错误提示 -->
        <div
          v-if="errorMessage"
          class="mt-6 rounded-xl border border-red-200 bg-red-50 p-4 dark:border-red-800/50 dark:bg-red-900/20"
        >
          <div class="flex items-start gap-3">
            <Icon name="exclamationCircle" size="md" class="flex-shrink-0 text-red-500" />
            <p class="text-sm text-red-700 dark:text-red-400">{{ errorMessage }}</p>
          </div>
        </div>

        <!-- 成功与启动过渡提示 -->
        <div
          v-if="installSuccess"
          class="mt-6 rounded-xl border border-green-200 bg-green-50 p-4 dark:border-green-800/50 dark:bg-green-900/20"
        >
          <div class="flex items-start gap-3">
            <svg
              v-if="!serviceReady"
              class="h-5 w-5 flex-shrink-0 animate-spin text-green-500"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                class="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                stroke-width="4"
              ></circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              ></path>
            </svg>
            <Icon v-else name="checkCircle" size="md" class="flex-shrink-0 text-green-500" />
            <div>
              <p class="text-sm font-medium text-green-700 dark:text-green-400">
                配置成功！正在启动主服务并准备跳转...
              </p>
              <p class="mt-1 text-sm text-green-600 dark:text-green-500">
                {{
                  serviceReady
                    ? '主服务已就绪，正在进入系统...'
                    : '服务启动中，请稍候...'
                }}
              </p>
            </div>
          </div>
        </div>

        <!-- 单个主操作按钮 -->
        <div class="mt-8">
          <button
            v-if="!installSuccess"
            @click="performInstall"
            :disabled="!canProceed || installing"
            class="btn btn-primary w-full py-3 text-base font-semibold shadow-md"
          >
            <svg
              v-if="installing"
              class="-ml-1 mr-2 inline h-5 w-5 animate-spin"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                class="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                stroke-width="4"
              ></circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              ></path>
            </svg>
            <span>{{ installing ? '正在初始化并启动服务...' : '完成配置并启动 Sub2API' }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '@/stores/auth'
import { testDatabase, testRedis, install, type InstallRequest } from '@/api/setup'
import { buildGatewayUrl } from '@/api/client'
import Select from '@/components/common/Select.vue'
import Icon from '@/components/icons/Icon.vue'

const { t } = useI18n()
const authStore = useAuthStore()

// 挂载时清除所有旧凭据，确保是崭新纯净的配置界面
onMounted(() => {
  authStore.clearAuth()
  localStorage.removeItem('auth_token')
  localStorage.removeItem('refresh_token')
  localStorage.removeItem('user')
})

const showAdvanced = ref(false)
const errorMessage = ref('')
const installSuccess = ref(false)

// 数据库与 Redis 默认预置状态
const testingDb = ref(false)
const testingRedis = ref(false)
const dbConnected = ref(false)
const redisConnected = ref(false)
const installing = ref(false)
const serviceReady = ref(false)

const confirmPassword = ref('')

const sslModeOptions = [
  { value: 'disable', label: 'Disable' },
  { value: 'require', label: 'Require' },
  { value: 'verify-ca', label: 'Verify CA' },
  { value: 'verify-full', label: 'Verify Full' }
]

const getCurrentPort = () => {
  const port = window.location.port
  if (port) return parseInt(port, 10)
  return window.location.protocol === 'https:' ? 443 : 80
}

const formData = reactive<InstallRequest>({
  database: {
    host: '127.0.0.1',
    port: 5432,
    user: 'sub2api',
    password: 'sub2api_password',
    dbname: 'sub2api',
    sslmode: 'disable'
  },
  redis: {
    host: '127.0.0.1',
    port: 6379,
    username: '',
    password: '',
    db: 0,
    enable_tls: false
  },
  admin: {
    email: '',
    password: ''
  },
  server: {
    host: '0.0.0.0',
    port: getCurrentPort(),
    mode: 'release'
  }
})

// 仅需检查管理员邮箱与密码
const canProceed = computed(() => {
  return Boolean(
    formData.admin.email &&
    formData.admin.password.length >= 8 &&
    formData.admin.password === confirmPassword.value
  )
})

async function testDatabaseConnection() {
  testingDb.value = true
  errorMessage.value = ''
  dbConnected.value = false

  try {
    await testDatabase(formData.database)
    dbConnected.value = true
  } catch (error: unknown) {
    const err = error as { response?: { data?: { detail?: string; message?: string } }; message?: string }
    errorMessage.value =
      err.response?.data?.detail || err.response?.data?.message || err.message || 'Connection failed'
  } finally {
    testingDb.value = false
  }
}

async function testRedisConnection() {
  testingRedis.value = true
  errorMessage.value = ''
  redisConnected.value = false

  try {
    await testRedis(formData.redis)
    redisConnected.value = true
  } catch (error: unknown) {
    const err = error as { response?: { data?: { detail?: string; message?: string } }; message?: string }
    errorMessage.value =
      err.response?.data?.detail || err.response?.data?.message || err.message || 'Connection failed'
  } finally {
    testingRedis.value = false
  }
}

async function performInstall() {
  installing.value = true
  errorMessage.value = ''

  try {
    await install(formData)
    installSuccess.value = true
    waitForServiceRestart()
  } catch (error: unknown) {
    const err = error as { response?: { data?: { detail?: string; message?: string } }; message?: string }
    errorMessage.value =
      err.response?.data?.detail || err.response?.data?.message || err.message || 'Installation failed'
    showAdvanced.value = true
  } finally {
    installing.value = false
  }
}

// 轮询主服务公共接口，主服务一旦就绪立刻跳转登录页
async function waitForServiceRestart() {
  const maxAttempts = 60
  const interval = 800

  // 稍等 1 秒让向导服务关闭并拉起主服务
  await new Promise((resolve) => setTimeout(resolve, 1000))

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      const response = await fetch(buildGatewayUrl('/api/v1/settings/public'), {
        method: 'GET',
        cache: 'no-store'
      })

      if (response.ok) {
        serviceReady.value = true
        delete (window as any).__NEEDS_SETUP__
        setTimeout(() => {
          window.location.href = '/login'
        }, 800)
        return
      }
    } catch {
      // 重启过渡中等待下次重试
    }

    await new Promise((resolve) => setTimeout(resolve, interval))
  }

  errorMessage.value = t('setup.status.timeout')
}
</script>
