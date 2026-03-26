import { MaterialSymbolIcon } from "@modules/landing/components/material-symbol-icon"

type IconTone = "primary" | "secondary"

type DosageCard = {
  icon: string
  title: string
  iconTone: IconTone
  borderTone?: IconTone
}

const DOSAGE_CARDS: DosageCard[] = [
  { icon: "pill", title: "Tablets", iconTone: "primary" },
  {
    icon: "medical_services",
    title: "Capsules",
    iconTone: "secondary",
    borderTone: "secondary",
  },
  { icon: "colorize", title: "Eye/Ear Drops", iconTone: "primary" },
  {
    icon: "vaccines",
    title: "Injections",
    iconTone: "primary",
    borderTone: "primary",
  },
  { icon: "sanitizer", title: "Creams", iconTone: "secondary" },
  {
    icon: "science",
    title: "Dry Syrups",
    iconTone: "secondary",
    borderTone: "secondary",
  },
]

const ICON_CONTAINER_CLASS: Record<IconTone, string> = {
  primary:
    "bg-[var(--apx-primary-fixed)] group-hover:bg-[var(--apx-primary)]",
  secondary:
    "bg-[var(--apx-secondary-fixed)] group-hover:bg-[var(--apx-secondary)]",
}

const ICON_TEXT_CLASS: Record<IconTone, string> = {
  primary: "text-[var(--apx-primary)] group-hover:text-white",
  secondary: "text-[var(--apx-secondary)] group-hover:text-white",
}

const BORDER_CLASS: Record<IconTone, string> = {
  primary: "border-b-4 border-[color:rgb(150_73_0/0.2)]",
  secondary: "border-b-4 border-[color:rgb(51_107_0/0.2)]",
}

export default function DosageFormsSection() {
  return (
    <section id="products" className="bg-[var(--apx-surface-container-low)] py-24">
      <div className="mx-auto max-w-screen-2xl px-8">
        <div className="mb-16 flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
          <div className="max-w-2xl">
            <p className="mb-4 text-sm font-bold uppercase tracking-[0.2em] text-[var(--apx-primary)]">
              Therapeutic Range
            </p>
            <h2 className="apx-font-headline text-4xl font-bold">Comprehensive Dosage Forms</h2>
          </div>
          <div className="mx-12 mb-4 hidden h-px flex-grow bg-[color:rgb(221_193_176/0.3)] md:block" />
          <p className="max-w-xs font-serif italic text-[var(--apx-on-surface-variant)]">
            Engineered for bioavailability and patient compliance.
          </p>
        </div>

        <div className="grid grid-cols-2 gap-6 md:grid-cols-4 lg:grid-cols-6">
          {DOSAGE_CARDS.map((card) => (
            <div
              key={card.title}
              className={`ambient-shadow group flex flex-col items-center rounded-xl bg-[var(--apx-surface-container-lowest)] p-8 text-center transition-transform duration-300 hover:-translate-y-2 ${
                card.borderTone ? BORDER_CLASS[card.borderTone] : ""
              }`}
            >
              <div
                className={`mb-6 flex h-16 w-16 items-center justify-center rounded-full transition-colors ${ICON_CONTAINER_CLASS[card.iconTone]}`}
              >
                <MaterialSymbolIcon
                  name={card.icon}
                  className={`text-3xl ${ICON_TEXT_CLASS[card.iconTone]}`}
                />
              </div>
              <h3 className="apx-font-headline font-bold text-[var(--apx-on-surface)]">
                {card.title}
              </h3>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
