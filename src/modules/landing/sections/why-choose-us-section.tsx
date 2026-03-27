import type { LucideIcon } from "lucide-react"
import { Globe, Settings2, ShieldCheck } from "lucide-react"

type FeatureItem = {
  icon: LucideIcon
  title: string
  description: string
}

const FEATURES: FeatureItem[] = [
  {
    icon: Settings2,
    title: "Advanced R&D",
    description: "Innovative formulations developed by our in-house R&D team using evidence-based research and advanced testing.",
  },
  {
    icon: ShieldCheck,
    title: "WHO-GMP Quality",
    description: "All facilities are WHO-GMP certified with rigorous multi-stage quality control at every production step.",
  },
  {
    icon: Globe,
    title: "End-to-End Logistics",
    description: "Reliable delivery across 86+ countries via air, sea, and land with precise tracking and full documentation.",
  },
]

export default function WhyChooseUsSection() {
  return (
    <section
      id="why-choose-us"
      className="bg-[var(--apx-surface)] py-16 lg:py-24"
    >
      <div className="mx-auto max-w-screen-2xl px-8">
        <div className="flex lg:flex-row flex-col items-start gap-10">

          {/* Left: intro block */}
          <div className="w-full lg:w-1/3">
            <h2 className="apx-font-headline text-4xl font-bold">
              Why Choose Apindex?
            </h2>
            <p className="mt-4 text-lg leading-relaxed text-[var(--apx-on-surface-variant)]">
              Precision is the hallmark of pharmaceutical leadership. A company
              matured to deliver global solutions with modern manufacturing and
              uncompromising quality standards.
            </p>
          </div>

          {/* Right: feature columns */}
          <div className="grid grid-cols-1 gap-8 sm:grid-cols-3 w-full lg:w-2/3">
            {FEATURES.map((item) => {
              const Icon = item.icon
              return (
                <div key={item.title}>
                  <Icon
                    aria-hidden="true"
                    className="h-12 w-12 text-[var(--apx-primary)]"
                    strokeWidth={1.4}
                  />
                  <h3 className="apx-font-headline mt-5 text-base font-extrabold uppercase tracking-wide text-[var(--apx-on-surface)]">
                    {item.title}
                  </h3>
                  <p className="mt-2 text-lg leading-relaxed text-[var(--apx-on-surface-variant)]">
                    {item.description}
                  </p>
                </div>
              )
            })}
          </div>

        </div>
      </div>
    </section>
  )
}
