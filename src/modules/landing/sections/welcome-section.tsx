import Image from "next/image"

const WELCOME_IMAGE_URL =
  "https://lh3.googleusercontent.com/aida-public/AB6AXuAqn5mGy4tBW7R-mFwByWYGx2rc1xuPI8beh1p8OKwZb1nhKY9ANVEOWgYA97BhbNqskkNwVBPGjRk5paTpQSFnonLojpwaXbtJAmUl8Ui4zynW85S7UMzIUAdOVgYRU9ALRRaYWKL4v7PQkgjxKH5GfoDjEWGFQWYJ0_MP8ZVVo2u0pIVOBf5c5Oty3TXeJG3YDF7eO21qn2JTMnRRM1N-Dc9FvSF3zNQhKIoOWJatBRZDKZU8TnTqRrr4QyBdgxhfqyRbYSYbgZI"

export default function WelcomeSection() {
  return (
    <section id="welcome" className="bg-[var(--apx-surface)] py-16 lg:py-24">
      <div className="mx-auto max-w-screen-2xl px-8">
        <div className="grid grid-cols-1 items-center gap-12 lg:grid-cols-2">
          {/* Left: text content */}
          <div className="space-y-6">
            <p className="text-sm font-bold uppercase tracking-[0.2em] text-[var(--apx-primary)]">
              Welcome to Apindex
            </p>
            <h2 className="apx-font-headline text-4xl font-bold">
              A Legacy of Trust in{" "}
              <span className="text-[var(--apx-primary)]">Pharmaceutical</span>{" "}
              Excellence
            </h2>
            <p className="text-lg leading-relaxed text-[var(--apx-on-surface-variant)]">
              Apindex Pharmaceutical Pvt. Ltd. is a WHO-GMP certified company
              dedicated to delivering high-quality, affordable medicines to
              patients across the globe. With over two decades of experience,
              we have built a reputation for reliability, innovation, and
              uncompromising quality.
            </p>
            <p className="leading-relaxed text-[var(--apx-on-surface-variant)]">
              Our portfolio of 1500+ products spans diverse therapeutic
              categories, exported to 86+ countries. We combine modern
              manufacturing infrastructure with research-driven formulations
              to meet international regulatory standards consistently.
            </p>
          </div>

          {/* Right: image */}
          <div className="relative h-[420px] overflow-hidden rounded-2xl lg:h-[500px]">
            <Image
              fill
              sizes="(min-width: 1024px) 50vw, 100vw"
              src={WELCOME_IMAGE_URL}
              alt="Apindex Pharmaceutical modern manufacturing facility production line"
              className="object-cover"
            />
          </div>
        </div>
      </div>
    </section>
  )
}
