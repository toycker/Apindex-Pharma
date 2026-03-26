import type { IconType } from "react-icons"
import { MdAdjust, MdRemoveRedEye } from "react-icons/md"

type PurposeCard = {
  title: string
  description: string
  icon: IconType
  tone: "primary" | "secondary"
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

const ICON_TONE_CLASS: Record<PurposeCard["tone"], string> = {
  primary: "bg-[color:rgb(150_73_0/0.08)] text-[var(--apx-primary)]",
  secondary: "bg-[color:rgb(51_107_0/0.1)] text-[var(--apx-secondary)]",
}

export default function AboutPurposeSection() {
  return (
    <section className="bg-[var(--apx-surface-container-low)] py-8 sm:py-10">
      <div className="mx-auto grid max-w-[1240px] gap-5 px-4 sm:px-8 md:grid-cols-2">
        {PURPOSE_CARDS.map((card) => {
          const Icon = card.icon

          return (
            <article
              key={card.title}
              className="rounded-[4px] bg-[var(--apx-surface)] px-6 py-6 shadow-[0_10px_26px_rgba(86,67,54,0.04)]"
            >
              <div
                className={`mb-4 flex h-8 w-8 items-center justify-center rounded-full ${ICON_TONE_CLASS[card.tone]}`}
              >
                <Icon aria-hidden="true" className="text-sm" />
              </div>
              <h3 className="apx-font-headline text-[22px] font-bold text-[var(--apx-on-surface)]">
                {card.title}
              </h3>
              <p className="mt-3 max-w-xl text-[13px] leading-6 text-[var(--apx-on-surface-variant)] sm:text-[14px]">
                {card.description}
              </p>
            </article>
          )
        })}
      </div>
    </section>
  )
}
