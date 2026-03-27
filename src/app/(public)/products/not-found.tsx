import Link from "next/link"

export default function ProductsNotFound() {
  return (
    <div className="apx-landing apx-font-body min-h-screen bg-[var(--apx-surface)] text-[var(--apx-on-surface)]">
      <main className="!pb-0 pt-20">
        <section className="mx-auto flex min-h-[60vh] w-full max-w-screen-2xl flex-col items-center justify-center px-6 py-20 text-center md:px-8">
          <span className="mb-4 text-xs font-bold uppercase tracking-[0.3em] text-[var(--apx-primary)]">
            Product Not Found
          </span>
          <h1 className="apx-font-headline text-4xl font-extrabold tracking-tight text-[var(--apx-on-surface)] md:text-5xl">
            This product is not available in the public catalog.
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-8 text-[var(--apx-on-surface-variant)]">
            The product may be inactive, archived, or the link may be incorrect. Browse the
            current product catalog to review the available pharmaceutical entries.
          </p>
          <div className="mt-8 flex flex-wrap justify-center gap-3">
            <Link
              href="/products"
              className="rounded-xl bg-[var(--apx-primary)] px-6 py-3 text-sm font-bold text-white transition-colors hover:bg-[var(--apx-primary-container)]"
            >
              Back to Products
            </Link>
            <Link
              href="/"
              className="rounded-xl border border-[color:rgb(150_73_0/0.18)] bg-white px-6 py-3 text-sm font-bold text-[var(--apx-primary)] transition-colors hover:border-[var(--apx-primary)]"
            >
              Return Home
            </Link>
          </div>
        </section>
      </main>
    </div>
  )
}