import type { IconType } from "react-icons"
import {
  MdBiotech,
  MdFactory,
  MdGavel,
  MdInventory2,
  MdVerified,
} from "react-icons/md"
import SectionBadge from "@modules/common/components/section-badge"

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
  high: "bg-surface-high",
  low: "bg-surface-low",
}

const ICON_TONE_CLASS: Record<ServiceCard["iconTone"], string> = {
  primary: "text-primary",
  secondary: "text-secondary",
}

export default function ServicesSection() {
  return (
    <section id="infrastructure" className="bg-surface py-16 lg:py-24">
      <div className="mx-auto grid max-w-screen-2xl items-center gap-12 px-8 lg:grid-cols-2">
        {/* Text content — shown first on mobile via order */}
        <div className="order-1 space-y-6 lg:order-2 lg:space-y-10">
          <SectionBadge tone="secondary">Our Capabilities</SectionBadge>
          <h2 className="section-heading">
            Precision at every <span className="italic text-secondary">molecular</span>{" "}
            level.
          </h2>
          <p className="section-description">
            At Apindex, we combine industrial-scale efficiency with meticulous
            pharmaceutical oversight. Our services are designed to bridge the gap
            between complex chemistry and patient-ready solutions.
          </p>
          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-secondary-fixed">
              <MdVerified
                aria-hidden="true"
                className="text-on-secondary-container"
              />
            </div>
            <div>
              <p className="font-bold">Quality Assured</p>
              <p className="text-sm text-on-surface-variant">
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
                className={`space-y-4 rounded-xl p-6 lg:p-8 ${SURFACE_CLASS[card.surface]} ${card.offset ? "lg:translate-y-8" : ""} ${card.orderClass ?? ""}`}
              >
                <Icon
                  aria-hidden="true"
                  className={`text-4xl ${ICON_TONE_CLASS[card.iconTone]}`}
                />
                <h3 className="apx-font-headline text-lg font-bold lg:text-xl">{card.title}</h3>
                <p className="text-sm leading-relaxed text-on-surface-variant">
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
