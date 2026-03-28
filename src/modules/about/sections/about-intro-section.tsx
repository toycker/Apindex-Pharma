import Image from "next/image"
import SectionBadge from "@modules/common/components/section-badge"

const INTRO_IMAGE_URL =
  "https://images.unsplash.com/photo-1582719471384-894fbb16e074?auto=format&fit=crop&w=900&q=80"

export default function AboutIntroSection() {
  return (
    <section className="bg-surface py-16 lg:py-24">
      <div className="content-container">
        <div className="grid grid-cols-1 items-center gap-12 lg:grid-cols-2">
          {/* Left: text content */}
          <div className="space-y-6">
            <SectionBadge tone="primary">About Us</SectionBadge>
            <h2 className="section-heading">
              Precision in Chemistry,
              <span className="block text-secondary">Vitality in Life</span>
            </h2>
            <p className="section-description">
              Apindex Pharmaceuticals operates at the intersection of science,
              compliance, and dependable manufacturing. Our facilities and quality
              systems are built to support regulated supply with consistency at every
              stage of production.
            </p>
            <p className="section-description">
              From formulation planning to export execution, we align technical rigor
              with long-term partner trust, helping customers scale safely across
              domestic and international markets.
            </p>
          </div>

          {/* Right: image */}
          <div className="relative h-[420px] overflow-hidden rounded-2xl lg:h-[500px]">
            <Image
              fill
              sizes="(min-width: 1024px) 50vw, 100vw"
              src={INTRO_IMAGE_URL}
              alt="Apindex team member working in a pharmaceutical laboratory"
              className="object-cover object-center"
            />
          </div>
        </div>
      </div>
    </section>
  )
}
