import type { PublicProductDetail } from "@/lib/data/public-product-detail"
import FooterSection from "@/modules/landing/sections/footer-section"
import TopNavBar from "@/modules/landing/sections/top-nav-bar"
import ProductBreadcrumbsSection from "@/modules/products/sections/product-breadcrumbs-section"
import ProductDetailContentSection from "@/modules/products/sections/product-detail-content-section"
import ProductHeroSection from "@/modules/products/sections/product-hero-section"

type ProductDetailPageTemplateProps = {
  product: PublicProductDetail
}

export default function ProductDetailPageTemplate({
  product,
}: ProductDetailPageTemplateProps) {
  return (
    <div className="apx-landing apx-font-body min-h-screen bg-[var(--apx-surface)] text-[var(--apx-on-surface)]">
      <TopNavBar />
      <main className="!pb-0 pt-20">
        <ProductBreadcrumbsSection product={product} />
        <ProductHeroSection product={product} />
        <ProductDetailContentSection product={product} />
      </main>
      <FooterSection />
    </div>
  )
}

