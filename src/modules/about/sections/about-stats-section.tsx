import type { IconType } from "react-icons"
import { MdLanguage, MdScience, MdVerified } from "react-icons/md"

type StatTone = "primary" | "secondary" | "accent"

type StatItem = {
  value: string
  label: string
  icon: IconType
  tone: StatTone
}

const STAT_ITEMS: StatItem[] = [
  { value: "86+", label: "Export Markets", icon: MdLanguage, tone: "primary" },
  { value: "500+", label: "Product SKUs", icon: MdScience, tone: "secondary" },
  { value: "100%", label: "Quality Focus", icon: MdVerified, tone: "accent" },
]

const ICON_TONE_CLASS: Record<StatTone, string> = {
  primary: "bg-primary/[0.08] text-primary",
  secondary: "bg-secondary/[0.08] text-secondary",
  accent: "bg-primary-container/[0.12] text-primary-container",
}

export default function AboutStatsSection() {
  return (
    <section className="bg-surface-low py-16 lg:py-24">
      <div className="content-container grid gap-8 md:grid-cols-3">
        {STAT_ITEMS.map((item) => {
          const Icon = item.icon

          return (
            <div
              key={item.label}
              className="rounded-2xl border border-outline-variant/30 bg-surface-lowest px-6 py-8 text-center"
            >
              <div
                className={`mx-auto mb-3 flex h-8 w-8 items-center justify-center rounded-full ${ICON_TONE_CLASS[item.tone]}`}
              >
                <Icon aria-hidden="true" className="text-sm" />
              </div>
              <div className="apx-font-headline text-5xl font-extrabold leading-none text-on-surface">
                {item.value}
              </div>
              <p className="mt-2 text-[10px] font-bold uppercase tracking-[0.15em] text-on-surface-variant">
                {item.label}
              </p>
            </div>
          )
        })}
      </div>
    </section>
  )
}
