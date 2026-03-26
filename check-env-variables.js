const REQUIRED_ENV_VARS = [
  "NEXT_PUBLIC_SUPABASE_URL",
  "NEXT_PUBLIC_SUPABASE_ANON_KEY",
]

const PRODUCT_MEDIA_ENV_VAR = "NEXT_PUBLIC_R2_PUBLIC_URL"

module.exports = function checkEnvVariables() {
  const missing = REQUIRED_ENV_VARS.filter(
    (envName) => !process.env[envName] || process.env[envName]?.trim() === ""
  )

  if (missing.length > 0) {
    console.warn(
      `[env] Missing required environment variables: ${missing.join(", ")}`
    )
  }

  if (!process.env[PRODUCT_MEDIA_ENV_VAR]?.trim()) {
    console.warn(
      `[env] Product media is not configured. Set ${PRODUCT_MEDIA_ENV_VAR} to your public R2/CDN URL to render product images correctly.`
    )
  }
}
