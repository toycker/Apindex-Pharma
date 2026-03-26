type Certification = {
  label: string
  sublabel: string
  tone: "primary" | "secondary"
}

const CERTIFICATIONS: Certification[] = [
  { label: "WHO", sublabel: "GMP Certified", tone: "primary" },
  { label: "ISO", sublabel: "9001:2015", tone: "secondary" },
  { label: "GLP", sublabel: "Compliance", tone: "primary" },
  { label: "FDCA", sublabel: "Approved", tone: "secondary" },
  { label: "MSME", sublabel: "Registered", tone: "primary" },
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
          {CERTIFICATIONS.map((certification) => (
            <div key={certification.label} className="flex flex-col items-center">
              <div
                className={`mb-2 flex h-16 w-16 items-center justify-center rounded-full border-2 font-black ${TONE_CLASS[certification.tone]}`}
              >
                {certification.label}
              </div>
              <span className="text-[10px] font-bold uppercase tracking-tighter">
                {certification.sublabel}
              </span>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
