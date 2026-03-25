import type { Metadata } from "next"
import { inter } from "@lib/fonts"
import Providers from "./providers"
import "@/styles/globals.css"

export const metadata: Metadata = {
  title: {
    template: "%s | Toycker",
    default: "Toycker Admin",
  },
  description: "Admin panel for Toycker backend operations.",
  icons: {
    icon: "/favicon.png",
  },
}

export default function RootLayout(props: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      data-mode="light"
      suppressHydrationWarning
      className={inter.variable}
    >
      <body suppressHydrationWarning className="font-sans">
        <Providers>{props.children}</Providers>
      </body>
    </html>
  )
}
