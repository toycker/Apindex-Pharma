export type ProductCompositionItem = {
  ingredient: string
  role: string | null
}

export type ProductPharmaDetails = {
  tradeName: string | null
  availableStrength: string | null
  packing: string | null
  packInsertLeaflet: boolean | null
  therapeuticUse: string | null
  productionCapacity: string | null
  pharmacodynamics: string | null
  therapeuticClass: string | null
  uses: string[]
  sideEffects: string[]
  composition: ProductCompositionItem[]
  brochureUrl: string | null
}

export type ProductPharmaDetailsFormDefaults = {
  tradeName: string
  availableStrength: string
  packing: string
  packInsertLeaflet: "" | "yes" | "no"
  therapeuticUse: string
  productionCapacity: string
  pharmacodynamics: string
  therapeuticClass: string
  usesText: string
  sideEffectsText: string
  compositionText: string
  brochureUrl: string
}

type UnknownRecord = Record<string, unknown>

function isRecord(value: unknown): value is UnknownRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value)
}

function toNullableTrimmedString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null
  }

  const trimmedValue = value.trim()
  return trimmedValue ? trimmedValue : null
}

function parseStringArray(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value
      .map((entry) => toNullableTrimmedString(entry))
      .filter((entry): entry is string => Boolean(entry))
  }

  const singleValue = toNullableTrimmedString(value)
  if (!singleValue) {
    return []
  }

  return singleValue
    .split(/\r?\n/)
    .map((entry) => entry.trim())
    .filter(Boolean)
}

function parseComposition(value: unknown): ProductCompositionItem[] {
  if (!Array.isArray(value)) {
    return []
  }

  return value
    .map((entry) => {
      if (!isRecord(entry)) {
        return null
      }

      const ingredient = toNullableTrimmedString(entry.ingredient)
      if (!ingredient) {
        return null
      }

      return {
        ingredient,
        role: toNullableTrimmedString(entry.role),
      }
    })
    .filter((entry): entry is ProductCompositionItem => Boolean(entry))
}

function hasPharmaDetailsContent(details: ProductPharmaDetails): boolean {
  return Boolean(
    details.tradeName ||
      details.availableStrength ||
      details.packing ||
      details.packInsertLeaflet !== null ||
      details.therapeuticUse ||
      details.productionCapacity ||
      details.pharmacodynamics ||
      details.therapeuticClass ||
      details.uses.length > 0 ||
      details.sideEffects.length > 0 ||
      details.composition.length > 0 ||
      details.brochureUrl
  )
}

function parsePackInsertLeaflet(value: unknown): boolean | null {
  if (typeof value === "boolean") {
    return value
  }

  if (typeof value !== "string") {
    return null
  }

  const normalizedValue = value.trim().toLowerCase()
  if (normalizedValue === "yes" || normalizedValue === "true") {
    return true
  }

  if (normalizedValue === "no" || normalizedValue === "false") {
    return false
  }

  return null
}

function parseCompositionLines(value: string): ProductCompositionItem[] {
  return value
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const separatorIndex = line.indexOf("|")

      if (separatorIndex === -1) {
        return {
          ingredient: line,
          role: null,
        }
      }

      const ingredient = line.slice(0, separatorIndex).trim()
      const role = line.slice(separatorIndex + 1).trim()

      if (!ingredient) {
        return null
      }

      return {
        ingredient,
        role: role || null,
      }
    })
    .filter((entry): entry is ProductCompositionItem => Boolean(entry))
}

function parseTextareaList(value: string): string[] {
  return value
    .split(/\r?\n/)
    .map((entry) => entry.trim())
    .filter(Boolean)
}

function getTrimmedFormValue(formData: FormData, key: string): string {
  const value = formData.get(key)

  if (typeof value !== "string") {
    return ""
  }

  return value.trim()
}

export function parseProductPharmaDetails(value: unknown): ProductPharmaDetails | null {
  if (!isRecord(value)) {
    return null
  }

  const details: ProductPharmaDetails = {
    tradeName: toNullableTrimmedString(value.trade_name),
    availableStrength: toNullableTrimmedString(value.available_strength),
    packing: toNullableTrimmedString(value.packing),
    packInsertLeaflet: parsePackInsertLeaflet(value.pack_insert_leaflet),
    therapeuticUse: toNullableTrimmedString(value.therapeutic_use),
    productionCapacity: toNullableTrimmedString(value.production_capacity),
    pharmacodynamics: toNullableTrimmedString(value.pharmacodynamics),
    therapeuticClass: toNullableTrimmedString(value.therapeutic_class),
    uses: parseStringArray(value.uses),
    sideEffects: parseStringArray(value.side_effects),
    composition: parseComposition(value.composition),
    brochureUrl: toNullableTrimmedString(value.brochure_url),
  }

  return hasPharmaDetailsContent(details) ? details : null
}

export function getProductPharmaDetails(metadata: unknown): ProductPharmaDetails | null {
  if (!isRecord(metadata)) {
    return null
  }

  return parseProductPharmaDetails(metadata.pharma_details)
}

export function buildProductPharmaDetailsFormDefaults(
  details: ProductPharmaDetails | null
): ProductPharmaDetailsFormDefaults {
  return {
    tradeName: details?.tradeName ?? "",
    availableStrength: details?.availableStrength ?? "",
    packing: details?.packing ?? "",
    packInsertLeaflet:
      details?.packInsertLeaflet === true
        ? "yes"
        : details?.packInsertLeaflet === false
          ? "no"
          : "",
    therapeuticUse: details?.therapeuticUse ?? "",
    productionCapacity: details?.productionCapacity ?? "",
    pharmacodynamics: details?.pharmacodynamics ?? "",
    therapeuticClass: details?.therapeuticClass ?? "",
    usesText: details?.uses.join("\n") ?? "",
    sideEffectsText: details?.sideEffects.join("\n") ?? "",
    compositionText:
      details?.composition
        .map((item) =>
          item.role ? `${item.ingredient} | ${item.role}` : item.ingredient
        )
        .join("\n") ?? "",
    brochureUrl: details?.brochureUrl ?? "",
  }
}

export function buildProductPharmaDetailsFromFormData(
  formData: FormData
): ProductPharmaDetails | null {
  const tradeName = getTrimmedFormValue(formData, "pharma_trade_name")
  const availableStrength = getTrimmedFormValue(
    formData,
    "pharma_available_strength"
  )
  const packing = getTrimmedFormValue(formData, "pharma_packing")
  const packInsertLeafletValue = getTrimmedFormValue(
    formData,
    "pharma_pack_insert_leaflet"
  )
  const therapeuticUse = getTrimmedFormValue(formData, "pharma_therapeutic_use")
  const productionCapacity = getTrimmedFormValue(
    formData,
    "pharma_production_capacity"
  )
  const pharmacodynamics = getTrimmedFormValue(
    formData,
    "pharma_pharmacodynamics"
  )
  const therapeuticClass = getTrimmedFormValue(
    formData,
    "pharma_therapeutic_class"
  )
  const usesText = getTrimmedFormValue(formData, "pharma_uses")
  const sideEffectsText = getTrimmedFormValue(formData, "pharma_side_effects")
  const compositionText = getTrimmedFormValue(formData, "pharma_composition")
  const brochureUrl = getTrimmedFormValue(formData, "pharma_brochure_url")

  const details: ProductPharmaDetails = {
    tradeName: tradeName || null,
    availableStrength: availableStrength || null,
    packing: packing || null,
    packInsertLeaflet: parsePackInsertLeaflet(packInsertLeafletValue),
    therapeuticUse: therapeuticUse || null,
    productionCapacity: productionCapacity || null,
    pharmacodynamics: pharmacodynamics || null,
    therapeuticClass: therapeuticClass || null,
    uses: parseTextareaList(usesText),
    sideEffects: parseTextareaList(sideEffectsText),
    composition: parseCompositionLines(compositionText),
    brochureUrl: brochureUrl || null,
  }

  return hasPharmaDetailsContent(details) ? details : null
}

export function mergeProductPharmaDetailsMetadata(
  metadata: UnknownRecord,
  details: ProductPharmaDetails | null
): UnknownRecord {
  const nextMetadata: UnknownRecord = { ...metadata }

  if (details) {
    nextMetadata.pharma_details = {
      trade_name: details.tradeName,
      available_strength: details.availableStrength,
      packing: details.packing,
      pack_insert_leaflet: details.packInsertLeaflet,
      therapeutic_use: details.therapeuticUse,
      production_capacity: details.productionCapacity,
      pharmacodynamics: details.pharmacodynamics,
      therapeutic_class: details.therapeuticClass,
      uses: details.uses,
      side_effects: details.sideEffects,
      composition: details.composition,
      brochure_url: details.brochureUrl,
    }
  } else {
    delete nextMetadata.pharma_details
  }

  return nextMetadata
}
