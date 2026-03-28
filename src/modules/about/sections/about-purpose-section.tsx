import type { IconType } from "react-icons"
import { MdAdjust, MdRemoveRedEye } from "react-icons/md"
import SectionBadge from "@modules/common/components/section-badge"

type PurposeTone = "primary" | "secondary"

type PurposeCard = {
  title: string
  description: string
  icon: IconType
  tone: PurposeTone
}

const PURPOSE_CARDS: PurposeCard[] = [
  {
    title: "Our Mission",
    description:
      "To deliver reliable, accessible pharmaceutical solutions backed by disciplined process controls, responsive partnerships, and continuous quality improvement.",
    icon: MdAdjust,
    tone: "primary",
  },
  {
    title: "Our Vision",
    description:
      "To be recognized as a globally trusted pharmaceutical company where precision manufacturing, ethics, and better patient outcomes move together.",
    icon: MdRemoveRedEye,
    tone: "secondary",
  },
]

const ICON_TONE_CLASS: Record<PurposeTone, string> = {
  primary: "bg-primary/[0.08] text-primary",
  secondary: "bg-secondary/[0.08] text-secondary",
}

export default function AboutPurposeSection() {
  return (
    <section className="bg-surface py-16 lg:py-24">
      <div className="content-container">
        <div className="mb-12 space-y-4">
          <SectionBadge tone="primary">Our Purpose</SectionBadge>
          <h2 className="section-heading">Mission &amp; Vision</h2>
        </div>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-2">
          {PURPOSE_CARDS.map((card) => {
            const Icon = card.icon

            return (
              <article
                key={card.title}
                className="rounded-xl bg-surface-low p-6 lg:p-8"
              >
                <div
                  className={`mb-4 flex h-8 w-8 items-center justify-center rounded-full ${ICON_TONE_CLASS[card.tone]}`}
                >
                  <Icon aria-hidden="true" className="text-sm" />
                </div>
                <h3 className="apx-font-headline text-lg font-bold lg:text-xl">
                  {card.title}
                </h3>
                <p className="mt-3 text-sm leading-relaxed text-on-surface-variant">
                  {card.description}
                </p>
              </article>
            )
          })}
        </div>
      </div>
    </section>
  )
}
