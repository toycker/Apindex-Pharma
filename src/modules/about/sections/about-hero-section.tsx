import Image from "next/image"
import SectionBadge from "@modules/common/components/section-badge"

const HERO_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuB9OeoJelP19gJ61a_CZc1AphOtugOZk73qmzACyIZcGDDHK5HgS-rxwuWfZ-NO6NYL0T19uOgtnbKrkK2Z9ycu116q7Rt9PjpiKZGVoZeL-KGt-7qsTKYy5p34dpUEtwHkU-RMF3mDfX0J97K_NA8OrH_EXsncoXpkCfn7KS0QFI2vMYbdEVT78X2sONELE1qFEMXtdaf_hp_ILmfTauyBYiqKlRY9bvz-fRZQaFyAiUj7jk38ipwTrxQ5pelo6SIEA4lGmmrgFYU"

export default function AboutHeroSection() {
  return (
    <section className="relative flex min-h-screen items-end overflow-hidden pt-20">
      {/* Background image */}
      <div className="absolute inset-0 z-0">
        <Image
          fill
          priority
          sizes="100vw"
          src={HERO_IMAGE_URL}
          alt="Apindex pharmaceutical manufacturing environment with stainless steel process equipment"
          className="object-cover object-center"
        />
        {/* Dark overlay */}
        <div className="absolute inset-0 bg-black/40" />
      </div>

      {/* Content — bottom left */}
      <div className="relative z-10 w-full max-w-3xl px-8 pb-20 md:px-14">
        {/* <SectionBadge tone="primary" variant="light">WHO-GMP Certified</SectionBadge> */}
        <h1 className="mt-4 text-4xl font-extrabold leading-[1.15] tracking-wide text-white sm:text-5xl md:text-6xl">
          About <span className="text-primary">Apindex</span> Pharmaceuticals
        </h1>
        <p className="mt-3 text-sm leading-relaxed text-white/70 sm:text-base">
          A global pharmaceutical manufacturing partner focused on trusted quality,
          export readiness, and better healthcare outcomes through precision-driven
          processes.
        </p>
      </div>
    </section>
  )
}
