import type { IconType } from "react-icons"
import { MdLanguage, MdScience, MdVerified } from "react-icons/md"

type StatItem = {
  value: string
  label: string
  icon: IconType
  tone: "primary" | "secondary" | "accent"
}

const STAT_ITEMS: StatItem[] = [
  { value: "86+", label: "Export Markets", icon: MdLanguage, tone: "primary" },
  { value: "500+", label: "Product SKUs", icon: MdScience, tone: "secondary" },
  { value: "100%", label: "Quality Focus", icon: MdVerified, tone: "accent" },
]

const ICON_TONE_CLASS: Record<StatItem["tone"], string> = {
  primary: "bg-[color:rgb(150_73_0/0.08)] text-[var(--apx-primary)]",
  secondary: "bg-[color:rgb(51_107_0/0.1)] text-[var(--apx-secondary)]",
  accent: "bg-[color:rgb(245_130_32/0.12)] text-[var(--apx-primary-container)]",
}

export default function AboutStatsSection() {
  return (
    <section className="bg-[var(--apx-surface-container-low)] py-8 sm:py-10">
      <div className="mx-auto grid max-w-[1240px] gap-4 px-4 sm:px-8 md:grid-cols-3">
        {STAT_ITEMS.map((item) => {
          const Icon = item.icon

          return (
            <div
              key={item.label}
              className="rounded-[4px] border border-[color:rgb(221_193_176/0.32)] bg-white px-6 py-5 text-center shadow-[0_12px_28px_rgba(86,67,54,0.05)]"
            >
              <div
                className={`mx-auto mb-3 flex h-8 w-8 items-center justify-center rounded-full ${ICON_TONE_CLASS[item.tone]}`}
              >
                <Icon aria-hidden="true" className="text-sm" />
              </div>
              <div className="apx-font-headline text-[34px] font-extrabold leading-none text-[var(--apx-on-surface)]">
                {item.value}
              </div>
              <p className="mt-2 text-[11px] font-semibold uppercase tracking-[0.18em] text-zinc-500">
                {item.label}
              </p>
            </div>
          )
        })}
      </div>
    </section>
  )
}
