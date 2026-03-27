import type { IconType } from "react-icons"
import {
  MdBiotech,
  MdFactory,
  MdGavel,
  MdInventory2,
  MdVerified,
} from "react-icons/md"

type ServiceCard = {
  icon: IconType
  title: string
  description: string
  surface: "low" | "high"
  iconTone: "primary" | "secondary"
  offset?: boolean
  orderClass?: string
}

const SERVICE_CARDS: ServiceCard[] = [
  {
    icon: MdFactory,
    title: "Contract Manufacturing",
    description:
      "State-of-the-art facilities dedicated to high-volume production for global partners.",
    surface: "high",
    iconTone: "primary",
    offset: true,
  },
  {
    icon: MdBiotech,
    title: "3rd Party Manufacturing", 
    description:
      "Scalable solutions for private label brands with strict adherence to WHO-GMP.",
    surface: "low",
    iconTone: "secondary",
  },
  {
    icon: MdInventory2,
    title: "Generic Products",
    description:
      "High-efficacy generic formulations providing accessible healthcare to millions.",
    surface: "low",
    iconTone: "secondary",
    offset: true,
    orderClass: "order-4 lg:order-none",
  },
  {
    icon: MdGavel,
    title: "Institutional Tenders",
    description:
      "Reliable supply chain for governmental and health organization procurement.",
    surface: "high",
    iconTone: "primary",
    orderClass: "order-3 lg:order-none",
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
    <section id="infrastructure" className="bg-[var(--apx-surface)] py-16 lg:py-24">
      <div className="mx-auto grid max-w-screen-2xl items-center gap-12 px-8 lg:grid-cols-2">
        {/* Text content — shown first on mobile via order */}
        <div className="order-1 space-y-6 lg:order-2 lg:space-y-10">
          <p className="text-sm font-bold uppercase tracking-[0.2em] text-[var(--apx-secondary)]">
            Our Capabilities
          </p>
          <h2 className="apx-font-headline text-3xl font-extrabold leading-tight sm:text-4xl lg:text-5xl">
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
              <MdVerified
                aria-hidden="true"
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

        {/* Service cards — shown second on mobile */}
        <div className="order-2 grid grid-cols-1 gap-4 lg:grid-cols-2 lg:order-1 lg:gap-6">
          {SERVICE_CARDS.map((card) => {
            const Icon = card.icon
            return (
              <div
                key={card.title}
                className={`space-y-4 rounded-xl p-6 ${SURFACE_CLASS[card.surface]} ${card.offset ? "lg:translate-y-8" : ""} ${card.orderClass ?? ""}`}
              >
                <Icon
                  aria-hidden="true"
                  className={`text-4xl ${ICON_TONE_CLASS[card.iconTone]}`}
                />
                <h3 className="apx-font-headline text-lg font-bold lg:text-xl">{card.title}</h3>
                <p className="text-sm leading-relaxed text-[var(--apx-on-surface-variant)]">
                  {card.description}
                </p>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
