import { MaterialSymbolIcon } from "@modules/landing/components/material-symbol-icon"

type ServiceCard = {
  icon: string
  title: string
  description: string
  surface: "low" | "high"
  iconTone: "primary" | "secondary"
  offset?: boolean
}

const SERVICE_CARDS: ServiceCard[] = [
  {
    icon: "factory",
    title: "Contract Manufacturing",
    description:
      "State-of-the-art facilities dedicated to high-volume production for global partners.",
    surface: "high",
    iconTone: "primary",
    offset: true,
  },
  {
    icon: "biotech",
    title: "3rd Party Manufacturing",
    description:
      "Scalable solutions for private label brands with strict adherence to WHO-GMP.",
    surface: "low",
    iconTone: "secondary",
  },
  {
    icon: "inventory_2",
    title: "Generic Products",
    description:
      "High-efficacy generic formulations providing accessible healthcare to millions.",
    surface: "low",
    iconTone: "secondary",
    offset: true,
  },
  {
    icon: "gavel",
    title: "Institutional Tenders",
    description:
      "Reliable supply chain for governmental and health organization procurement.",
    surface: "high",
    iconTone: "primary",
  },
]

const SURFACE_CLASS: Record<ServiceCard["surface"], string> = {
  high: "bg-[var(--apx-surface-container-high)]",
  low: "bg-[var(--apx-surface-container-low)]",
}

const ICON_TONE_CLASS: Record<ServiceCard["iconTone"], string> = {
  primary: "text-[var(--apx-primary)]",
  secondary: "text-[var(--apx-secondary)]",
}

export default function ServicesSection() {
  return (
    <section id="infrastructure" className="bg-[var(--apx-surface)] py-32">
      <div className="mx-auto grid max-w-screen-2xl items-center gap-20 px-8 lg:grid-cols-2">
        <div className="grid grid-cols-2 gap-6">
          {SERVICE_CARDS.map((card) => (
            <div
              key={card.title}
              className={`space-y-4 rounded-xl p-8 ${SURFACE_CLASS[card.surface]} ${
                card.offset ? "translate-y-8" : ""
              }`}
            >
              <MaterialSymbolIcon
                name={card.icon}
                filled
                className={`text-4xl ${ICON_TONE_CLASS[card.iconTone]}`}
              />
              <h3 className="apx-font-headline text-xl font-bold">{card.title}</h3>
              <p className="text-sm leading-relaxed text-[var(--apx-on-surface-variant)]">
                {card.description}
              </p>
            </div>
          ))}
        </div>

        <div className="space-y-10 lg:pl-12">
          <p className="text-sm font-bold uppercase tracking-[0.2em] text-[var(--apx-secondary)]">
            Our Capabilities
          </p>
          <h2 className="apx-font-headline text-5xl font-extrabold leading-tight">
            Precision at every <span className="italic text-[var(--apx-primary)]">molecular</span>{" "}
            level.
          </h2>
          <p className="text-lg leading-relaxed text-[var(--apx-on-surface-variant)]">
            At Apindex, we combine industrial-scale efficiency with meticulous
            pharmaceutical oversight. Our services are designed to bridge the gap
            between complex chemistry and patient-ready solutions.
          </p>
          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--apx-secondary-fixed)]">
              <MaterialSymbolIcon
                name="verified"
                className="text-[var(--apx-on-secondary-container)]"
              />
            </div>
            <div>
              <p className="font-bold">Quality Assured</p>
              <p className="text-sm text-[var(--apx-on-surface-variant)]">
                ISO 9001:2015 &amp; WHO-GMP Standards
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
