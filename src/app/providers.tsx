"use client"

import type { ReactNode } from "react"
import ToastDisplay from "@modules/common/components/toast-display"
import { ToastProvider } from "@modules/common/context/toast-context"

export default function Providers({ children }: { children: ReactNode }) {
  return (
    <ToastProvider>
      <ToastDisplay />
      {children}
    </ToastProvider>
  )
}
