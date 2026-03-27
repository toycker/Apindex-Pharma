import type { ReactNode } from "react"
import PublicLayout from "@/modules/layout/public/templates/public-layout"

type PublicRouteLayoutProps = {
  children: ReactNode
}

export default function PublicRouteLayout({
  children,
}: PublicRouteLayoutProps) {
  return <PublicLayout>{children}</PublicLayout>
}