import type {
  Product,
  ProductImage,
  ProductVariant,
} from "@/lib/supabase/types/index"

export const PRODUCT_MEDIA_CONFIG_ERROR =
  "Product images require NEXT_PUBLIC_R2_PUBLIC_URL to be set to your public R2/CDN URL."

function trimTrailingSlashes(value: string): string {
  return value.replace(/\/+$/, "")
}

function trimLeadingSlashes(value: string): string {
  return value.replace(/^\/+/, "")
}

function isAbsoluteUrl(value: string): boolean {
  return /^https?:\/\//i.test(value)
}

function normalizeLegacyUrl(value: string): string {
  const trimmedValue = value.trim()

  if (!trimmedValue) {
    return ""
  }

  if (/^https?:\/\/(?:www\.)?toycker\.in\/uploads\//i.test(trimmedValue)) {
    const [, path = ""] = trimmedValue.split(/toycker\.in\//i)
    return path
  }

  return trimmedValue
}

export function getProductMediaBaseUrl(): string | null {
  const publicUrl = process.env.NEXT_PUBLIC_R2_PUBLIC_URL?.trim()

  if (!publicUrl) {
    return null
  }

  return trimTrailingSlashes(publicUrl)
}

export function buildProductFileUrl(key: string): string {
  const baseUrl = getProductMediaBaseUrl()
  const cleanKey = trimLeadingSlashes(key.trim())

  if (!baseUrl) {
    throw new Error(PRODUCT_MEDIA_CONFIG_ERROR)
  }

  if (!cleanKey) {
    throw new Error("Cannot build a product image URL without a storage key.")
  }

  return `${baseUrl}/${cleanKey}`
}

export function resolveProductImageUrl(
  url: string | null | undefined
): string | null {
  if (!url) {
    return null
  }

  const normalizedUrl = normalizeLegacyUrl(url)
  if (!normalizedUrl) {
    return null
  }

  if (isAbsoluteUrl(normalizedUrl)) {
    return normalizedUrl
  }

  const cleanPath = trimLeadingSlashes(normalizedUrl)
  if (!cleanPath) {
    return null
  }

  const baseUrl = getProductMediaBaseUrl()
  if (!baseUrl) {
    return null
  }

  return `${baseUrl}/${cleanPath}`
}

export const fixUrl = resolveProductImageUrl

export function normalizeProductVariantImage(
  variant: ProductVariant
): ProductVariant {
  return {
    ...variant,
    image_url: resolveProductImageUrl(variant.image_url),
  }
}

function collectProductImages(product: Product): string[] {
  const rawImages: string[] = []

  if (Array.isArray(product.images)) {
    product.images.forEach((image: string | ProductImage) => {
      if (typeof image === "string") {
        rawImages.push(image)
        return
      }

      const imageUrl = image?.url?.trim()
      if (imageUrl) {
        rawImages.push(imageUrl)
      }
    })
  }

  if (product.image_url && !rawImages.includes(product.image_url)) {
    rawImages.unshift(product.image_url)
  }

  if (product.thumbnail && !rawImages.includes(product.thumbnail)) {
    rawImages.unshift(product.thumbnail)
  }

  return Array.from(
    new Set(
      rawImages
        .map((imageUrl) => resolveProductImageUrl(imageUrl))
        .filter((imageUrl): imageUrl is string => Boolean(imageUrl))
    )
  )
}

export function normalizeProductImage(product: Product): Product {
  const normalizedImages = collectProductImages(product)
  const mainImage =
    resolveProductImageUrl(product.image_url) ??
    resolveProductImageUrl(product.thumbnail) ??
    normalizedImages[0] ??
    null

  return {
    ...product,
    title: product.name,
    image_url: mainImage,
    thumbnail: mainImage ?? resolveProductImageUrl(product.thumbnail),
    images: normalizedImages,
    variants: product.variants?.map(normalizeProductVariantImage),
    related_combinations: product.related_combinations?.map((combination) => ({
      ...combination,
      related_product: normalizeProductImage(combination.related_product),
    })),
  }
}
