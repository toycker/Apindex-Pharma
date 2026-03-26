import type { IconType } from "react-icons"
import {
  MdBusiness,
  MdFactCheck,
  MdHealthAndSafety,
  MdScience,
  MdWorkspacePremium,
} from "react-icons/md"

type Certification = {
  label: string
  sublabel: string
  icon: IconType
  tone: "primary" | "secondary"
}

const CERTIFICATIONS: Certification[] = [
  { label: "WHO", sublabel: "GMP Certified", icon: MdHealthAndSafety, tone: "primary" },
  { label: "ISO", sublabel: "9001:2015", icon: MdWorkspacePremium, tone: "secondary" },
  { label: "GLP", sublabel: "Compliance", icon: MdScience, tone: "primary" },
  { label: "FDCA", sublabel: "Approved", icon: MdFactCheck, tone: "secondary" },
  { label: "MSME", sublabel: "Registered", icon: MdBusiness, tone: "primary" },
]

const TONE_CLASS: Record<Certification["tone"], string> = {
  primary: "border-[var(--apx-primary)] text-[var(--apx-primary)]",
  secondary: "border-[var(--apx-secondary)] text-[var(--apx-secondary)]",
}

export default function CertificationsSection() {
  return (
    <section className="border-y border-[color:rgb(221_193_176/0.1)] bg-[var(--apx-surface-container-low)] py-16">
      <div className="mx-auto max-w-screen-2xl px-8">
        <div className="flex flex-wrap items-center justify-center gap-12 opacity-60 grayscale transition-opacity duration-500 hover:opacity-100 hover:grayscale-0">
          {CERTIFICATIONS.map((certification) => {
            const Icon = certification.icon

            return (
              <div key={certification.label} className="flex flex-col items-center">
                <div
                  className={`mb-2 flex h-16 w-16 items-center justify-center rounded-full border-2 ${TONE_CLASS[certification.tone]}`}
                >
                  <Icon aria-hidden="true" className="text-2xl" />
                </div>
                <span className="text-[10px] font-bold uppercase tracking-tighter">
                  {certification.label} {certification.sublabel}
                </span>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
