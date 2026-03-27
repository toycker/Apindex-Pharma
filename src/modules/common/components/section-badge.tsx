import { cn } from "@lib/util/cn"

type SectionBadgeProps = {
  tone?: "primary" | "secondary"
  variant?: "light" | "dark"
  className?: string
  children: React.ReactNode
}

const TONE_STYLES = {
  primary: {
    light: {
      wrapper: "border-primary/20 bg-primary/[0.08]",
      dot: "bg-primary",
      text: "text-primary",
    },
    dark: {
      wrapper: "border-primary-container/28 bg-primary-container/[0.09]",
      dot: "bg-primary-container",
      text: "text-primary-container",
    },
  },
  secondary: {
    light: {
      wrapper: "border-secondary/20 bg-secondary/[0.08]",
      dot: "bg-secondary",
      text: "text-secondary",
    },
    dark: {
      wrapper: "border-secondary-container/28 bg-secondary-container/[0.09]",
      dot: "bg-secondary-container",
      text: "text-secondary-container",
    },
  },
}

export default function SectionBadge({
  tone = "primary",
  variant = "light",
  className,
  children,
}: SectionBadgeProps) {
  const styles = TONE_STYLES[tone][variant]

  return (
    <div
      className={cn(
        "inline-flex items-center gap-2 rounded-full border px-4 py-1.5",
        styles.wrapper,
        className
      )}
    >
      <span className={cn("h-1.5 w-1.5 rounded-full", styles.dot)} />
      <span
        className={cn(
          "text-[11px] font-semibold uppercase tracking-[0.18em]",
          styles.text
        )}
      >
        {children}
      </span>
    </div>
  )
}
