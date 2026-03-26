import Image from "next/image"

const HERO_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuB9OeoJelP19gJ61a_CZc1AphOtugOZk73qmzACyIZcGDDHK5HgS-rxwuWfZ-NO6NYL0T19uOgtnbKrkK2Z9ycu116q7Rt9PjpiKZGVoZeL-KGt-7qsTKYy5p34dpUEtwHkU-RMF3mDfX0J97K_NA8OrH_EXsncoXpkCfn7KS0QFI2vMYbdEVT78X2sONELE1qFEMXtdaf_hp_ILmfTauyBYiqKlRY9bvz-fRZQaFyAiUj7jk38ipwTrxQ5pelo6SIEA4lGmmrgFYU"

export default function AboutHeroSection() {
  return (
    <section className="relative isolate overflow-hidden pt-20">
      <div className="relative min-h-[430px] sm:min-h-[500px]">
        <div className="absolute inset-0">
          <Image
            fill
            priority
            sizes="100vw"
            src={HERO_IMAGE_URL}
            alt="Apindex pharmaceutical manufacturing environment with stainless steel process equipment"
            className="object-cover object-center"
          />
          <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(12,42,55,0.86)_0%,rgba(18,86,111,0.66)_56%,rgba(54,188,214,0.35)_100%)]" />
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(4,24,34,0.1)_0%,rgba(4,24,34,0.38)_100%)]" />
          <div className="absolute inset-y-0 right-0 w-[18%] bg-[linear-gradient(180deg,rgba(98,244,255,0.24)_0%,rgba(98,244,255,0)_100%)]" />
        </div>

        <div className="relative z-10 mx-auto flex min-h-[430px] max-w-[1240px] items-end px-4 pb-10 pt-10 sm:min-h-[500px] sm:px-8 sm:pb-14">
          <div className="max-w-[560px] space-y-4">
            <span className="inline-flex rounded-full bg-[var(--apx-secondary-container)] px-3 py-1 text-[10px] font-bold uppercase tracking-[0.22em] text-[var(--apx-on-secondary-container)] sm:px-4 sm:text-xs">
              WHO-GMP Certified
            </span>
            <h1 className="apx-font-headline max-w-[420px] text-[40px] font-extrabold leading-[0.95] tracking-[-0.04em] text-white sm:max-w-[520px] sm:text-[64px]">
              About Apindex Pharmaceuticals
            </h1>
            <p className="max-w-[350px] text-sm leading-6 text-white/75 sm:max-w-[390px] sm:text-[15px]">
              A global pharmaceutical manufacturing partner focused on trusted quality,
              export readiness, and better healthcare outcomes through precision-driven
              processes.
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
