import type { Metadata } from "next"
import LoginTemplate from "@modules/account/templates/login-template"

export const metadata: Metadata = {
  title: "Admin Login",
  description: "Sign in to access the Toycker admin panel.",
}

type Props = {
  searchParams: Promise<{
    next?: string
    returnUrl?: string
  }>
}

export default async function Login(props: Props) {
  const searchParams = await props.searchParams
  return (
    <LoginTemplate
      next={searchParams.next}
      returnUrl={searchParams.returnUrl}
    />
  )
}
