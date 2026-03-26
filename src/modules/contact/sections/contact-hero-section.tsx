import Image from "next/image"

const HERO_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuBEFXE-WHcJL7z7BgfL-3RfLHqFl-JG2B6fKe3rTD9UiXFAOseO5RcXhU0HeJno2ds8auPwHEo0qCg0ooRAIH-saN30A7QGywplPIehskhjyVenWcYGcEswGDBp7aZXRPCImufUAnOTHtzYne2NnVCuzaxzQPwEytfjWju9CHv5-ptKMKdBi0Vlny2rPHUX8ovrkWzayGpC826JzZUcJoreMfKQOOSxEVpcwZvRvMPKcLOdSjl-Du4FbB7oOK4nksBbiq5JH1QCmwY"

export default function ContactHeroSection() {
  return (
    <section className="relative flex min-h-[614px] items-center overflow-hidden pt-20">
      <div className="absolute inset-0 z-0">
        <Image
          fill
          priority
          sizes="100vw"
          src={HERO_IMAGE_URL}
          alt="Modern high-tech pharmaceutical laboratory with glass partitions, stainless steel equipment and soft clean white lighting"
          className="object-cover"
        />
        <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(251,249,248,0.96)_30%,rgba(251,249,248,0.64)_100%)]" />
      </div>

      <div className="relative z-10 mx-auto w-full max-w-screen-2xl px-6 py-14 sm:px-8">
        <div className="max-w-[560px]">
          <span className="mb-6 inline-block rounded-full bg-[var(--apx-secondary-container)] px-4 py-1 text-[10px] font-bold uppercase tracking-[0.24em] text-[var(--apx-on-secondary-container)]">
            Global Reach
          </span>
          <h1 className="apx-font-headline mb-7 text-[56px] font-extrabold leading-[0.94] tracking-[-0.05em] text-[var(--apx-on-surface)] sm:text-[76px]">
            Contact <span className="text-[var(--apx-primary-container)]">Us</span>
          </h1>
          <p className="max-w-[510px] text-lg leading-[1.7] text-[var(--apx-on-surface-variant)]">
            Connecting global health innovations with precision partnerships. Reach
            out to our centers of excellence across the globe.
          </p>
        </div>
      </div>
    </section>
  )
}
