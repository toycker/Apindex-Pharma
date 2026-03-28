import Image from "next/image"

const AUTHOR_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuAmz7qGu1kSrO-j3LIFD3Oa_y98cJvLNgoaHSAkIg8ZR3tV6tTNlRJ4a20-nGSdkftbgdVnE63J0IzvHQSJ8UhUMtLDQu6ARjwMd5A3IhnMR4VIionc2I_47BNCiJK94YICDLLwOP1ux1rGpKCzg2cLC6BuPYdiPYIUtGuPWAa_tz58efwHzyQQYOeUk2YJLdZT3N7Y-HA4rvnPRJmZWfrdjEpot1fIYB5cy4wQXl9nLBCuHUGvLWqaKE7p6fAaQj1x3qYWmgxM5-4"

export default function AboutQuoteSection() {
  return (
    <section className="bg-surface-low py-16 lg:py-24">
      <div className="content-container">
        <div className="relative overflow-hidden rounded-2xl bg-surface px-8 py-10 sm:px-12 sm:py-14">
          <p className="mb-5 text-[11px] font-semibold uppercase tracking-[0.18em] text-primary">
            Leadership Perspective
          </p>
          <blockquote className="relative max-w-[820px] pr-10 sm:pr-16">
            <p className="apx-font-headline text-2xl font-medium italic leading-[1.4] tracking-tight text-on-surface/90 sm:text-4xl">
              &quot;Innovation at Apindex isn&apos;t just about molecules; it&apos;s about the
              human impact every capsule we manufacture has. Every promise of quality to a
              patient in Nairobi, London, or Mumbai.&quot;
            </p>
            <span className="pointer-events-none absolute -right-1 top-[-22px] text-[120px] leading-none text-on-surface-variant/20 sm:text-[160px]">
              &rdquo;
            </span>
          </blockquote>

          <div className="mt-7 flex items-center gap-3">
            <div className="relative h-9 w-9 overflow-hidden rounded-full">
              <Image
                fill
                sizes="36px"
                src={AUTHOR_IMAGE_URL}
                alt="Apindex leadership representative"
                className="object-cover"
              />
            </div>
            <div>
              <p className="text-sm font-semibold text-on-surface">Managing Director</p>
              <p className="text-xs text-on-surface-variant">Apindex Pharmaceuticals</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
