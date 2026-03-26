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
    <section className="bg-[var(--apx-surface-container-low)] py-16 sm:py-20">
      <div className="mx-auto max-w-[1240px] px-4 sm:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="apx-font-headline text-[30px] font-extrabold tracking-[-0.03em] text-[var(--apx-on-surface)] sm:text-[40px]">
            Validated Excellence
          </h2>
          <p className="mt-3 text-[12px] leading-6 text-[var(--apx-on-surface-variant)] sm:text-[13px]">
            The systems behind our manufacturing standards are designed for repeatable
            quality, reliable documentation, and confidence at scale.
          </p>
        </div>

        <div className="mt-10 grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
          {EXCELLENCE_CARDS.map((card) => {
            const Icon = card.icon

            return (
              <article
                key={card.title}
                className="rounded-[4px] border border-[color:rgb(221_193_176/0.28)] bg-white px-4 py-5 text-center"
              >
                <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-[10px] border border-[color:rgb(221_193_176/0.7)] bg-[var(--apx-surface-container-low)] text-[var(--apx-primary)]">
                  <Icon aria-hidden="true" className="text-xl" />
                </div>
                <h3 className="apx-font-headline mt-4 text-base font-bold text-[var(--apx-on-surface)]">
                  {card.title}
                </h3>
                <p className="mt-1 text-xs text-zinc-500">{card.subtitle}</p>
              </article>
            )
          })}
        </div>
      </div>
    </section>
  )
}
