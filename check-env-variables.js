const REQUIRED_ENV_VARS = [
  "NEXT_PUBLIC_SUPABASE_URL",
  "NEXT_PUBLIC_SUPABASE_ANON_KEY",
]

module.exports = function checkEnvVariables() {
  const missing = REQUIRED_ENV_VARS.filter(
    (envName) => !process.env[envName] || process.env[envName]?.trim() === ""
  )

  if (missing.length > 0) {
    console.warn(
      `[env] Missing required environment variables: ${missing.join(", ")}`
    )
  }
}
