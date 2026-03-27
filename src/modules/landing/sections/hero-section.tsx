import Image from "next/image"
import Link from "next/link"

const HERO_IMAGE_URL = "/team-labs.avif"

export default function HeroSection() {
  return (
    <section
      id="home"
      className="relative flex min-h-screen items-end overflow-hidden pt-20"
    >
      {/* Background Image */}
      <div className="absolute inset-0 z-0">
        <Image
          fill
          priority
          sizes="100vw"
          src={HERO_IMAGE_URL}
          alt="Pharmaceutical manufacturing facility with industrial reactors"
          className="h-full w-full object-cover"
        />
        {/* Dark overlay */}
        <div className="absolute inset-0 bg-black/40" />
      </div>

      {/* Content — bottom left */}
      <div className="relative z-10 w-full max-w-3xl px-8 pb-20 md:px-14">
        <h1 className="text-4xl font-extrabold uppercase leading-[1.15] tracking-wide text-white sm:text-5xl md:text-6xl">
          YOUR{" "}
          <span className="text-primary-container">TRUSTED PARTNER</span>
          <br />
          IN GLOBAL HEALTHCARE
        </h1>

        <p className="mt-3 text-sm leading-relaxed text-white/70 sm:text-base">
          WHO-GMP certified manufacturer delivering quality pharmaceutical
          products to 50+ countries — trusted by healthcare professionals
          worldwide.
        </p>

        <div className="mt-7 flex flex-wrap gap-3">
          <Link
            href="/products"
            className="rounded-lg bg-primary-container px-6 py-3 text-sm font-bold text-white transition-opacity hover:opacity-90"
          >
            Explore Our Products
          </Link>
          <Link
            href="/contact#contact-form"
            className="rounded-lg border border-white/50 bg-white/10 px-6 py-3 text-sm font-bold text-white backdrop-blur-sm transition-colors hover:bg-white/20"
          >
            Request a Quote
          </Link>
        </div>
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-7 left-1/2 z-10 -translate-x-1/2">
        <div className="flex h-9 w-6 items-start justify-center rounded-full border-2 border-white/60 pt-1.5">
          <div className="h-1.5 w-0.5 animate-[scrollDot_2s_ease-in-out_infinite] rounded-full bg-white/60" />
        </div>
      </div>
    </section>
  )
}
