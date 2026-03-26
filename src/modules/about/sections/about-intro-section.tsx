import Image from "next/image"

const INTRO_IMAGE_URL =
  "https://images.unsplash.com/photo-1582719471384-894fbb16e074?auto=format&fit=crop&w=900&q=80"

export default function AboutIntroSection() {
  return (
    <section className="bg-white py-14 sm:py-20">
      <div className="mx-auto grid max-w-[1240px] gap-8 px-4 sm:px-8 lg:grid-cols-[minmax(0,1.14fr)_320px] lg:items-start">
        <div className="max-w-[565px] pt-1">
          <h2 className="apx-font-headline text-[30px] font-extrabold leading-[1.08] tracking-[-0.03em] text-[var(--apx-on-surface)] sm:text-[44px]">
            Precision in Chemistry,
            <span className="block text-[var(--apx-secondary)]">Vitality in Life</span>
          </h2>
          <div className="mt-5 max-w-[525px] space-y-3 text-[13px] leading-6 text-[var(--apx-on-surface-variant)] sm:text-[14px]">
            <p>
              Apindex Pharmaceuticals operates at the intersection of science,
              compliance, and dependable manufacturing. Our facilities and quality
              systems are built to support regulated supply with consistency at every
              stage of production.
            </p>
            <p>
              From formulation planning to export execution, we align technical rigor
              with long-term partner trust, helping customers scale safely across
              domestic and international markets.
            </p>
          </div>
        </div>

        <div className="overflow-hidden rounded-[6px] bg-[var(--apx-surface-container-low)] shadow-[0_16px_34px_rgba(86,67,54,0.06)]">
          <div className="relative h-[260px] sm:h-[320px]">
            <Image
              fill
              sizes="(min-width: 1024px) 320px, 100vw"
              src={INTRO_IMAGE_URL}
              alt="Apindex team member working in a pharmaceutical laboratory"
              className="object-cover object-center"
            />
          </div>
          <div className="bg-[var(--apx-primary-container)] px-5 py-3">
            <span className="apx-font-headline text-base font-bold tracking-wide text-white">
              WHO-GMP
            </span>
          </div>
        </div>
      </div>
    </section>
  )
}
