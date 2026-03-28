import type { IconType } from "react-icons"
import {
  MdFactCheck,
  MdHealthAndSafety,
  MdScience,
  MdVerifiedUser,
  MdWorkspacePremium,
} from "react-icons/md"

type ExcellenceCard = {
  title: string
  subtitle: string
  icon: IconType
}

const EXCELLENCE_CARDS: ExcellenceCard[] = [
  { title: "WHO-GMP", subtitle: "Certified Plant", icon: MdHealthAndSafety },
  { title: "ISO 9001", subtitle: "Quality System", icon: MdWorkspacePremium },
  { title: "GLP", subtitle: "Lab Discipline", icon: MdScience },
  { title: "FDCA", subtitle: "Regulatory Ready", icon: MdFactCheck },
  { title: "QA", subtitle: "Batch Integrity", icon: MdVerifiedUser },
]

export default function AboutValidatedExcellenceSection() {
  return (
    <section className="bg-surface-low py-16 lg:py-24">
      <div className="content-container">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="section-heading">Validated Excellence</h2>
          <p className="mt-3 section-description">
            The systems behind our manufacturing standards are designed for repeatable
            quality, reliable documentation, and confidence at scale.
          </p>
        </div>

        <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
          {EXCELLENCE_CARDS.map((card) => {
            const Icon = card.icon

            return (
              <article
                key={card.title}
                className="rounded-xl border border-outline-variant/30 bg-surface-lowest px-4 py-6 text-center"
              >
                <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-xl border border-outline-variant/70 bg-surface-low text-primary">
                  <Icon aria-hidden="true" className="text-xl" />
                </div>
                <h3 className="apx-font-headline mt-4 text-base font-bold">
                  {card.title}
                </h3>
                <p className="mt-1 text-xs text-on-surface-variant">{card.subtitle}</p>
              </article>
            )
          })}
        </div>
      </div>
    </section>
  )
}
