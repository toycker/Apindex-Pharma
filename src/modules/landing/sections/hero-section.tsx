import Image from "next/image"

const HERO_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuB9OeoJelP19gJ61a_CZc1AphOtugOZk73qmzACyIZcGDDHK5HgS-rxwuWfZ-NO6NYL0T19uOgtnbKrkK2Z9ycu116q7Rt9PjpiKZGVoZeL-KGt-7qsTKYy5p34dpUEtwHkU-RMF3mDfX0J97K_NA8OrH_EXsncoXpkCfn7KS0QFI2vMYbdEVT78X2sONELE1qFEMXtdaf_hp_ILmfTauyBYiqKlRY9bvz-fRZQaFyAiUj7jk38ipwTrxQ5pelo6SIEA4lGmmrgFYU"

export default function HeroSection() {
  return (
    <section id="about" className="relative flex min-h-[921px] items-center overflow-hidden pt-20">
      <div className="absolute inset-0 z-0">
        <Image
          fill
          priority
          sizes="100vw"
          src={HERO_IMAGE_URL}
          alt="Ultra-modern pharmaceutical laboratory with clean white surfaces, high-tech glass equipment, and soft professional blue and orange lighting"
          className="h-full w-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-r from-[var(--apx-surface)] via-[color:rgb(251_249_248/0.8)] to-transparent" />
      </div>

      <div className="relative z-10 mx-auto grid w-full max-w-screen-2xl gap-12 px-8 md:grid-cols-2">
        <div className="space-y-8">
          <span className="inline-block rounded-full bg-[var(--apx-secondary-container)] px-3 py-1 text-xs font-bold uppercase tracking-widest text-[var(--apx-on-secondary-container)]">
            WHO-GMP CERTIFIED
          </span>
          <h1 className="apx-font-headline text-6xl font-extrabold leading-[1.1] tracking-tight text-[var(--apx-on-surface)] md:text-7xl">
            Your Trusted Partner in <span className="text-[var(--apx-primary)]">Global</span>{" "}
            Healthcare
          </h1>
          <p className="max-w-lg text-lg leading-relaxed text-[var(--apx-on-surface-variant)]">
            Innovating quality pharmaceutical solutions for a healthier world through
            precision chemistry and editorial-grade manufacturing standards.
          </p>
          <div className="flex flex-wrap gap-4 pt-4">
            <a
              href="#products"
              className="ambient-shadow rounded-xl bg-gradient-to-r from-[var(--apx-primary)] to-[var(--apx-primary-container)] px-8 py-4 font-bold text-white transition-transform hover:scale-95"
            >
              Explore Our Products
            </a>
            <a
              href="#contact"
              className="ambient-shadow rounded-xl bg-[var(--apx-secondary)] px-8 py-4 font-bold text-white transition-transform hover:scale-95"
            >
              Request a Quote
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}
