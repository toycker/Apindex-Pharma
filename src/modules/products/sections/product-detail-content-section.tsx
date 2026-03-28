import type { PublicProductDetail } from "@/lib/data/public-product-detail"
import {
  getProductDescriptionHtml,
  getProductDescriptionParagraphs,
} from "@/modules/products/lib/product-detail-ui"

type ProductDetailContentSectionProps = {
  product: PublicProductDetail
}

export default function ProductDetailContentSection({
  product,
}: ProductDetailContentSectionProps) {
  const descriptionHtml = getProductDescriptionHtml(product)
  const descriptionParagraphs = descriptionHtml
    ? null
    : getProductDescriptionParagraphs(product)

  return (
    <section className="content-container mt-8 pb-24">
      <div className="space-y-6">
        <div>
          <h2 className="apx-font-headline text-3xl font-extrabold tracking-tight text-on-surface md:text-[2.15rem]">
            What is {product.name}?
          </h2>
          <div className="mt-4 h-1.5 w-20 rounded-full bg-secondary" />
        </div>

        {descriptionHtml ? (
          <div
            className="rich-text-block text-lg leading-8 text-on-surface-variant"
            dangerouslySetInnerHTML={{ __html: descriptionHtml }}
          />
        ) : (
          <div className="space-y-4 text-lg leading-8 text-on-surface-variant">
            {descriptionParagraphs!.map((paragraph, index) => (
              <p key={`${product.id}-paragraph-${index + 1}`}>{paragraph}</p>
            ))}
          </div>
        )}
      </div>
    </section>
  )
}
