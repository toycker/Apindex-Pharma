import Image from "next/image"

const AUTHOR_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuAmz7qGu1kSrO-j3LIFD3Oa_y98cJvLNgoaHSAkIg8ZR3tV6tTNlRJ4a20-nGSdkftbgdVnE63J0IzvHQSJ8UhUMtLDQu6ARjwMd5A3IhnMR4VIionc2I_47BNCiJK94YICDLLwOP1ux1rGpKCzg2cLC6BuPYdiPYIUtGuPWAa_tz58efwHzyQQYOeUk2YJLdZT3N7Y-HA4rvnPRJmZWfrdjEpot1fIYB5cy4wQXl9nLBCuHUGvLWqaKE7p6fAaQj1x3qYWmgxM5-4"

export default function AboutQuoteSection() {
  return (
    <section className="bg-white py-14 sm:py-20">
      <div className="mx-auto max-w-[1240px] px-4 sm:px-8">
        <div className="relative overflow-hidden rounded-[6px] bg-[linear-gradient(180deg,#faf6f2_0%,#f7f4f1_100%)] px-7 py-8 sm:px-10 sm:py-10">
          <p className="mb-5 text-[10px] font-bold uppercase tracking-[0.26em] text-[color:rgb(150_73_0/0.62)]">
            Leadership Perspective
          </p>
          <blockquote className="relative max-w-[820px] pr-10 sm:pr-16">
            <p className="apx-font-headline text-[24px] font-medium italic leading-[1.4] tracking-[-0.02em] text-[color:rgb(86_67_54/0.9)] sm:text-[34px]">
              &quot;Innovation at Apindex isn&apos;t just about molecules; it&apos;s about the
              human impact every capsule we manufacture has. Every promise of quality to a
              patient in Nairobi, London, or Mumbai.&quot;
            </p>
            <span className="pointer-events-none absolute -right-1 top-[-22px] text-[120px] leading-none text-[color:rgb(86_67_54/0.09)] sm:text-[160px]">
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
              <p className="text-sm font-semibold text-[var(--apx-on-surface)]">Managing Director</p>
              <p className="text-xs text-zinc-500">Apindex Pharmaceuticals</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
