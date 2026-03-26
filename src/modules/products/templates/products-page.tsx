import type { PublicCatalogResult } from "@/lib/data/public-catalog"
import FooterSection from "@/modules/landing/sections/footer-section"
import TopNavBar from "@/modules/landing/sections/top-nav-bar"
import ProductsCatalogSection from "@/modules/products/sections/products-catalog-section"
import ProductsHeroSection from "@/modules/products/sections/products-hero-section"
import ProductsValidationSection from "@/modules/products/sections/products-validation-section"

type ProductsPageTemplateProps = {
  catalog: PublicCatalogResult
}

export default function ProductsPageTemplate({
  catalog,
}: ProductsPageTemplateProps) {
  return (
    <div className="apx-landing apx-font-body min-h-screen bg-[var(--apx-surface)] text-[var(--apx-on-surface)]">
      <TopNavBar activeLabel="Products" />
      <main className="!pb-0 pt-20">
        <ProductsHeroSection catalog={catalog} />
        <ProductsCatalogSection catalog={catalog} />
        <ProductsValidationSection />
      </main>
      <FooterSection />
    </div>
  )
}
